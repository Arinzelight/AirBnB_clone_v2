#!/usr/bin/python3
# Fabfile to delete out-of-date archives.

from fabric.api import env, local, run, lcd, cd

env.hosts = ["34.207.64.162", "52.201.221.50"]
env.user = "ubuntu"
env.key_filename = ["~/.ssh/id_rsa"]

def do_clean(number=0):
    """Delete out-of-date archives.

    Args:
        number (int): The number of archives to keep.

    If number is 0 or 1, keeps only the most recent archive. If
    number is 2, keeps the most and second-most recent archives,
    etc.
    """
    number = 1 if int(number) == 0 else int(number)

    # Local cleanup
    with lcd("versions"):
        local("ls -tr | head -n -{} | xargs -I {{}} rm -f {{}}".format(number))

    # Remote cleanup
    with cd("/data/web_static/releases"):
        archives = run("sudo ls -tr | grep web_static_").split()
        [archives.pop() for i in range(number)]
        [run("sudo rm -rf {}".format(a)) for a in archives]

# Run the fabric command
if __name__ == "__main__":
    local("fab -f 100-clean_web_static.py do_clean:number=2")

