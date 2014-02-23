#!/usr/bin/env python
######################################################################
#
# Email Status of SolusVM VPS's
# Designed as a Cron script
#
######################################################################
#
# Example
#
#Node0
#  bw:
#       15.5GB/1.0TB
#       [#---------------------------------------] 2%
#
#Node1
#  bw:
#       2.6GB/1000.0GB
#       [----------------------------------------] 0%
#
#Node2
#  hdd:
#       4.9GB/30.0GB
#       [######----------------------------------] 16%
# bw:
#      8.3GB/1.0TB
#       [----------------------------------------] 1%
#
#Node3
#  hdd:
#      23.7GB/50.0GB
#       [###################---------------------] 47%
#  bw:
#       372.8GB/500.0GB
#       [##############################----------] 75%
#
#
######################################################################
###### Settings start ################################################
######################################################################

# Hosts to check the status of (in order)
# Put as many as your want
HOSTS = [
	{
		'key': "XXXXX-00000-XXXXX", # API Key
		'hash': "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", # API hash
		'url': "https://usadmin.inceptionhosting.com", # API host
		'name': "Node0" # Name
	},
	{
		'key': "XXXXX-00000-XXXXX", # API Key
		'hash': "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", # API hash
		'url': "https://solus.fliphost.net", # API host
		'name': "Node1" # Name
	},
	{
		'key': "XXXXX-00000-XXXXX", # API Key
		'hash': "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", # API hash
		'url': "http://master.weloveservers.net", # API host
		'name': "Node2" # Name
	},
	{
		'key': "XXXXX-00000-XXXXX", # API Key
		'hash': "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", # API hash
		'url': "https://vpscp.ramnode.com", # API host
		'name': "Node3" # Name
	}
]

# Email Settings
# Uses the local email SMTP server, so watch out
EMAIL_FROM = "root@example.com"
EMAIL_TO = "admin@example.com"
EMAIL_SUBJECT = "Server Status Report"

# Possible values: "bw", "hdd", "mem" (in order)
CHECK = ["hdd", "bw", "mem"]

# Do not show blank values (Usually due to the server being a KVM/XEN)
REMOVE_BLANKS = True

# Steps (the size of the status bars)
STEPS = 40

######################################################################
###### Settings end ##################################################
######################################################################

import subprocess
import re
import os
import smtplib
from email.mime.text import MIMEText

######################################################################
###### Functions start ###############################################
######################################################################

def run(args):
	proc = subprocess.Popen([args], stdout=subprocess.PIPE, shell=True)
	(out, err) = proc.communicate()
	return out

def parseStatus(str):
	parser = re.compile(r'</*\w+>')
	array = parser.split(str)
	array = filter(None, array)
	lookup = {
		'status': array[0],
		'statusmsg': array[1],
		'vmstat': array[2],
		'hostname': array[3],
		'ipaddress': array[4],
		'hdd': parseType(array[5]),
		'bw': parseType(array[6]),
		'mem': parseType(array[7])
	}
	return lookup

def parseType(str):
	parser = re.compile(r',')
	array = parser.split(str)
	array = filter(None, array)
	lookup = {
		'max': sizeOf(array[0]),
		'used': sizeOf(array[1]),
		'left': sizeOf(array[2]), 
		'precent': array[3]
	}
	return lookup
	
def pullStatus(host):
	result = run(
		"curl -s \"" + host['url'] +
		"/api/client/command.php?key=" + host['key'] +
		"&hash=" + host['hash'] +
		"&action=status&bw=true&mem=true&hdd=true\""
	)
	return parseStatus(result)

def sizeOf(str):
	# http://stackoverflow.com/a/1094933/2001966
	num = float(str)
	for x in ['bytes','KB','MB','GB']:
		if num < 1024.0:
			return "%3.1f%s" % (num, x)
		num /= 1024.0
	return "%3.1f%s" % (num, 'TB')

def saveHost(host):
	status = pullStatus(host)
	str = ""
	for type in CHECK:
		if(not(REMOVE_BLANKS) or (status[type]['used'] != "0.0bytes")):
			str += "  " + type + ":" + "\n"
			str += "       " + status[type]['used'] + "/" + status[type]['max'] + "\n"
			str += "       " + statusBar(status[type]['precent']) + " " + status[type]['precent'] + "%" + "\n"
	return str
	
def statusBar(precent):
	value = float(precent)
	value = STEPS * (value / 100)
	value = round(value)
	value = int(value)
	str = ""
	for x in range(0, value):
		str += "#"
	for x in range(value, STEPS):
		str += "-"
		
	return "[" + str + "]"
	
######################################################################
###### Functions end #################################################
######################################################################

str = ""
for host in HOSTS:
	str += (host['name'] + "\n")
	str += (saveHost(host) + "\n")

msg = MIMEText(str)
msg['Subject'] = EMAIL_SUBJECT
msg['From'] = EMAIL_FROM
msg['To'] = EMAIL_TO

server = smtplib.SMTP( "localhost", 25 )
server.sendmail( EMAIL_FROM, EMAIL_TO, msg.as_string() )
server.quit()


