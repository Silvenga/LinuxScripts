server-speedtest
================

A script to test the network speeds and quality on a server, written in Bash.


### Features

`server-speedtest` runs multiple tests to assess your network speeds and quality:

* Download speed: 100MB file downloads from looking glasses around the globe
* speedtest.net: local upload and download speeds using a geographically close provider

Further tests are currently being written:

* Peering quality: traceroutes to major datacenters and some IXPs
* Response time: ping speeds to different locations

### Installation

You can either download the [raw file](https://github.com/iceTwy/server-speedtest/blob/master/server-speedtest) at its latest revision, or clone this repository:

`$ git clone https://github.com/iceTwy/server-speedtest.git`

Remember to make `server-speedtest` executable and you're good to go:

`$ chmod +x server-speedtest`

### Requirements

Currently, `server-speedtest` uses basic networking utilities - `wget`, `traceroute` and `ping`.

However, the speedtest.net check is carried out using @sivel's [speedtest-cli](https://github.com/sivel/speedtest-cli) tool. You don't need to install it, but it requires one of the following:

* Python 2.4 or above
* Python 3.x

### Usage

Just run `server-speedtest` in the directory in which it is located:

`$ ./server-speedtest`
