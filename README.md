#  ddFast 1.0.2

**ddFast** — a faster more simplified dd, built for iso flashing.
---

###  Install

To get started with the installation process you will
need to curl the repo & make it executable.
```bash
sudo curl -fsSL https://raw.githubusercontent.com/lucysgutz/ddFast/main/ddfast -o /usr/local/bin/ddfast
sudo chmod +x /usr/local/bin/ddfast
```


### Example Usage

```bash
sudo ddfast /path/to/image.iso /dev/sdX 
```

### How to update
```bash
sudo rm -rf /usr/local/lib/ddFast
sudo rm -f /usr/local/bin/ddfast
```

Then reinstall
```bash
sudo curl -fsSL https://raw.githubusercontent.com/lucysgutz/ddFast/main/ddfast -o /usr/local/bin/ddfast
sudo chmod +x /usr/local/bin/ddfast
```


