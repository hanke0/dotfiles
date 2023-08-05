#!/usr/bin/python3

import smtplib
import argparse
import mimetypes
from os.path import basename
from os import getenv
from email import message, policy
from email import utils as emailutils

parser = argparse.ArgumentParser(
    description="sendemail via smtp protocol",
    epilog='email address could be in pure format("foo@example.com") or format with usernmae "foo bar <foo@example.com>"',
)
parser.add_argument("--from", required=True, dest="from_", help="send email from address")
parser.add_argument("--to", required=True, action="append", help="send email to address")
parser.add_argument("--cc", action="append", help="carbon copy to address")
parser.add_argument("--subject", required=True, help="email subject")
parser.add_argument("--server", required=True, help="smtp server name")
parser.add_argument("--port", type=int, default=465, help="smtp server port")
parser.add_argument("--content", help="email content body")
parser.add_argument("--attachment", action="append", help="add attachment")
parser.add_argument("--user", help="username of login user")
parser.add_argument("--password", help="password of login user")
parser.add_argument("--quiet", action="store_true", help="quit on output")
printcontent = print

namespace = parser.parse_args()
if not namespace.content:
    namespace.content = ""
if namespace.quiet:

    def printcontent(*args, **kwargs):
        pass


msg = message.MIMEPart()
msg.set_charset("utf-8")
msg.add_header("Subject", namespace.subject)
msg.add_header("Date", emailutils.formatdate(localtime=True))
msg.add_header("From", namespace.from_)
msg.add_header("To", ", ".join(namespace.to))
if namespace.cc:
    msg.add_header("Cc", ", ".join(namespace.cc))
msg.set_content(namespace.content)
if namespace.attachment:
    for filename in namespace.attachment:
        ctype, encoding = mimetypes.guess_type(filename)
        if ctype is None or encoding is not None:
            # No guess could be made, or the file is encoded (compressed), so
            # use a generic bag-of-bits type.
            ctype = "application/octet-stream"
        maintype, subtype = ctype.split("/", 1)
        part = message.Message()
        with open(filename, "rb") as file:
            part.set_payload(file.read())
            msg.add_attachment(
                file.read(), maintype=maintype, subtype=subtype, filename=basename(filename)
            )

# initialize connection to our email server, we will use Outlook here
smtp = smtplib.SMTP_SSL(namespace.server, port=namespace.port)
smtp.ehlo()  # send the extended hello to our server
if namespace.user:
    if not namespace.password:
        namespace.password = getenv("SMTP_PASSWORD")
    smtp.login(namespace.user, namespace.password)
smtp.ehlo()
printcontent(msg.as_string(policy=policy.SMTPUTF8))
smtp.send_message(msg)
smtp.quit()
