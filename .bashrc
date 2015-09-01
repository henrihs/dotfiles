export PI="pi@192.168.0.3"
alias pilogin="ssh $PI"
alias pimount="sshfs $PI:/home/pi/temPirature/ /home/henrik/temPirature/"
alias pipull="ssh $PI 'cd temPirature && git pull'"
export PYTHONSTARTUP=~/.pythonrc

