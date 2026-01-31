#  ddFast 1.0.3

**ddFast** — a faster more simplified dd, built for iso flashing.
---

### Whats New?
I added a TUI to simplify it even further and even added automatic iso detection so that ddFast scans your system for any .iso files.
###  Install

To get started with the installation process you will
need to curl the repo & make it executable.
```bash
sudo curl -fsSL https://raw.githubusercontent.com/imt00dizzy/ddFast/main/ddfast -o /usr/local/bin/ddfast
sudo chmod +x /usr/local/bin/ddfast
```


### Example Usage

```bash
ddfast
```
It will then run lsblk for you to choose a target device, after it will prompt you to paste a path to your iso.

### How to update
```bash
sudo rm -rf /usr/local/lib/ddFast
sudo rm -f /usr/local/bin/ddfast
```

Then reinstall
```bash
sudo curl -fsSL https://raw.githubusercontent.com/imt00dizzy/ddFast/main/ddfast -o /usr/local/bin/ddfast
sudo chmod +x /usr/local/bin/ddfast
```


