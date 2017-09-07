

# ansible
```
added to ~stack/.bashrc or /etc/bash.bashrc:
export LC_ALL=C

sudo mount hos-4.0.1_01-1181.iso /media/cdrom
tar xvf /media/cdrom/hos/hos-4.0.1-20161110T130634Z.tar

~/hos-4.0.1/hos-init.bash

cli commond
To continue installation copy your cloud layout to:
    /home/stack/helion/my_cloud/definition
Then execute the installation playbooks:
    cd /home/stack/helion/hos/ansible
    git add -A
    git commit -m 'My config'
    ansible-playbook -i hosts/localhost cobbler-deploy.yml
    ansible-playbook -i hosts/localhost bm-reimage.yml
    ansible-playbook -i hosts/localhost config-processor-run.yml
    ansible-playbook -i hosts/localhost ready-deployment.yml
    cd /home/stack/scratch/ansible/next/hos/ansible
    ansible-playbook -i hosts/verb_hosts site.yml

http://15.119.6.128:79/dayzero/
```
