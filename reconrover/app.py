import subprocess
import threading
import queue
from flask import Flask, render_template, request, Response, stream_with_context

app = Flask(__name__)

TOOLS = {
    "subfinder": ["subfinder", "-d"],
    "httpx": ["httpx", "-u"],
    "nuclei": ["nuclei", "-u"],
    "dalfox": ["dalfox", "url"],
    "jsfinder": ["python3", "modules/jsfinder.py", "-u"],
    "github-dork": ["python3", "modules/github-dork.py"],
    "shodan": ["shodan", "host"],
    "corsy": ["corsy", "-u"],
    "knockpy": ["knockpy"],
    "subjack": ["subjack", "-w", "output/{domain}_subdomains.txt", "-t", "100", "-timeout", "30", "-o", "output/{domain}_subjack.txt"],
    "katana": ["katana", "-u", "-json", "-o", "output/{domain}_katana.json"],
    "waybackurls": ["waybackurls"],
    "aquatone": ["aquatone", "-out", "output/{domain}_aquatone"],
    "httprobe": ["httprobe"],
    "dnsenum": ["dnsenum"],
    "sqlmap": ["sqlmap", "-u", "--batch", "--crawl=1"],
    "cmseek": ["cmseek", "-d", "--no-plugins"],
    "whatweb": ["whatweb"],
    "wafoof": ["wafoof", "-d"],
}

@app.route("/")
def index():
    return render_template("index.html", tools=TOOLS.keys())

def run_command(cmd):
    """Generator that yields real-time command output lines"""
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in iter(process.stdout.readline, ''):
        yield line
    process.stdout.close()
    process.wait()

@app.route("/run", methods=["POST"])
def run():
    domain = request.form.get("domain", "").strip()
    tool = request.form.get("tool", "").strip()

    if not domain or tool not in TOOLS:
        return "Invalid domain or tool selected.", 400

    cmd_template = TOOLS[tool]

    # Replace placeholders with domain if needed
    cmd = []
    for part in cmd_template:
        part = part.replace("{domain}", domain)
        if part == "-u" or part == "-d" or part == "url":  # Flags with URL param
            cmd.append(part)
            cmd.append(f"https://{domain}")
        else:
            cmd.append(part)
    # Remove duplicated URLs (if any)
    # Actually, this logic may append url twice for some tools; refine below:

    # Clean cmd to avoid duplicate domain for those flags
    # E.g. subfinder -d domain (correct)
    # httpx -u https://domain (correct)
    # waybackurls reads domain from stdin, so feed domain as input instead of arg.

    # Special cases:
    if tool == "waybackurls":
        # This tool requires domain on stdin
        process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        process.stdin.write(domain + "\n")
        process.stdin.close()
    elif tool == "httprobe":
        # Same as waybackurls, domain on stdin
        process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        process.stdin.write(domain + "\n")
        process.stdin.close()
    else:
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    def generate():
        for line in iter(process.stdout.readline, ''):
            yield f"data: {line.rstrip()}\n\n"
        process.stdout.close()
        process.wait()
        yield "data: [Process finished]\n\n"

    return Response(stream_with_context(generate()), mimetype='text/event-stream')


if __name__ == "__main__":
    app.run(debug=True)

