from os import path
import sys
from setproctitle import setproctitle
import logging
from .msg import msg_program_launched, msg_program_finished

class OmniProgram:
    def __init__(self, log_path, log_level, log_format, log_date_format):
        self.name = path.splitext(path.basename(sys.argv[0]))[0]
        setproctitle(self.name)
        logging.basicConfig(filename=log_path + '/' + self.name + '.log', level=log_level, format=log_format, datefmt=log_date_format)
        self.log = logging.getLogger()
        self.log.info(msg_program_launched)

    def __del__(self):
        self.log.info(msg_program_finished)
