#!/usr/bin/env bash

echo "ooh, fun, a new hacker!"

echo -n "full name: "
read -r FULLNAME
echo -n "username: "
read -r USERNAME
echo -n "email: "
read -r EMAIL

# create the user
sudo useradd -m -G hackers -s /usr/bin/zsh "$USERNAME"
echo "$USERNAME" >> /shared/hackers.txt
yq w --inplace /shared/git-authors authors."$USERNAME" "$FULLNAME"
yq w --inplace /shared/git-authors email_addresses."$USERNAME" "$EMAIL"

# do their setup
sudo su --login "$USERNAME" -c "/shared/hacker-setup.sh"

# change their shell
sudo chsh -s /usr/bin/fish "$USERNAME"

# expire their password
sudo passwd -de "$USERNAME"

# create shared directories with all the other hackers
cat << EOF | python
import itertools, os, shutil, stat

with open("/shared/hackers.txt") as f:
    hackers = list(map((lambda x: x.strip()), f.readlines()))

all_pairs = list(map(sorted, list(itertools.combinations(hackers, 2))))
all_pairs_dirs = list(map((lambda pair: ",".join(pair)), all_pairs))

for dir in all_pairs_dirs:
  path = "/shared/" + dir
  try:
    os.mkdir(path)
    os.chmod(path, 0o0770 ^ stat.S_ISGID)
  except os.error:
    continue
EOF
