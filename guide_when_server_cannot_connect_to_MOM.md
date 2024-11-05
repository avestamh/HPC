qdel: Server could not connect to MOM

If you encounter this error “qdel: Server could not connect to MOM” and you are using OpenPBS or PBS Pro, your users might encounter a problem where you are unable to kill the job. Usually, the error above indicates there is a problem with `pbs_mom` on the compute node.

### Step 1: Check the Queue and check the node that the jobs lands on

```
# qstat -a (for summary)

# qstat -n (You will see where the nodes the job lands)
```

### Step 2: Try to kill as cluster administrator.

```
# qdel
```

*If you are not able to delete the job somehow:*

### Step 3: Try restarting PBS Mom on the client

```
# service pbs_mom restart
```

### Step 4: If Step 3 is not workable, it might be due to connection issues or hardware problems. Try:

```
# ssh compute_node_1
```

If you cannot, you have to remote KVM into the server to take a look.

### Step 5: At the very beginning, check the status:

```
/sbin/service pbs_mom status
```

If it shows down, follow the steps above, and if it doesn’t show anything, just restart the node:

```
shutdown -r now
```
