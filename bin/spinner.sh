#!/bin/bash

spinner_chars="/-\|"
spinner_len=4
spinner_i=0

spin()
{
  echo -en "${spinner_chars:$spinner_i:1}" "\r"
  spinner_i=$(( ($spinner_i + 1) % $spinner_len ))
}
