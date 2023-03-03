
# dynamic Remote IP

This is a small (and unsecure) hack, mimicking a dynamic DNS server without running a DNS.
It works leveraging on the accessibility of a remote website, capable of php.

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

## The problem

We have a *remote* PC that connects to the internet and gets its IP address by DHCP. 
Despite our IT department linked the PC's MAC address to a fixed IP address, the IP changes unpredictably. 

We then want to connect to the *remote* PC (e.g. by ssh) and sometimes, the expected IP does not work. 
We do however pay a web hosting server (i.e. the *cloud*) without ssh access.


## The hack

- A cron job is run on the *remote* every hour launching a bash script;
- This script tells the *cloud* the *remote*'s IP, by accessing a php script on the *cloud*;
- The *cloud* stores on a file on disk the IP and makes it available;
- Whenever the *cloud* receives the request from another PC, it serves this file with the IP inside;


## The details

The cron job, running on the *remote*, calls a customized bash script (dyndns.sh). 
This script gets the IP and uses curl/wget to send a request to the *cloud*, calling a customized php page and passing some information to it.
The information is made of two elements: a key and the IP. If they key matches what the php expects, then the php script stores the IP on a file.
Both the name of the php script and the name of the file generated are difficult to guess.

When needed, any other computer running a bash script (getip.sh - using curl/wget) can get the *remote*'s IP and make it available.



## Installation

On the *remote* machine, run the install script we provide by something like

```bash
  chmod +x ./install.sh
  ./install.sh
```

The install scripts asks the user a few information, such as:
- the full path on the hosted web space, where the customized php script will reside (e.g. https://www.example.com/mysecretfolder/)
- a name for the host (i.e. the *remote* machine; e.g. PABLO)
- a random string of letters and numbers (e.g. 327h2hbdza) as a *shared key*;

It creates 3 (custom) 3 files:

- 327h2hbdza.php  (e.g.), to be uploaded to https://www.example.com/mysecretfolder/
- getip_PABLO.sh  (e.g.), to be installed on every other computer
- dyndns.sh       to be placed in the root folder, reachable by the cron job



## Dependencies

- [curl](https://curl.se) or [wget](https://www.gnu.org/software/wget/)
- the `sha256sum` command
- 

It also assumes that your public IP address can be obtained by invoking `hostname -I` from bash. If not, you have to dig into the code and uncomment the alternative methods to get the ip (e.g. ifconfig, grep, bash-fu, etc.).

## Acknowledgements

 - @davide-italy (for guidance and inspiration)
 - [Readme.so](https://readme.so)


## Authors

- [@adam-says](https://www.github.com/adam-says)
- [@mgiugliano](https://www.github.com/mgiugliano)


## Feedback

If you have any feedback, please reach out to us via email/mastodon/etc.


## License

[MIT](https://choosealicense.com/licenses/mit/)


## Screenshots

![App Screenshot](/sketch.png)

