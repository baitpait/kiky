"""Static file server with SPA fallback (serves index.html for app routes)."""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8082
ROOT = os.path.dirname(os.path.abspath(__file__))
if len(sys.argv) > 2:
    ROOT = os.path.abspath(sys.argv[2])

os.chdir(ROOT)


class SpaHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            index = os.path.join(path, "index.html")
            if os.path.isfile(index):
                return super().do_GET()
        elif os.path.isfile(path):
            return super().do_GET()
        self.path = "/index.html"
        return super().do_GET()

    def log_message(self, fmt, *args):
        if args and str(args[0]).startswith("GET /"):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), SpaHandler)
    print(f"SPA server: http://localhost:{PORT}  (root: {ROOT})")
    server.serve_forever()
