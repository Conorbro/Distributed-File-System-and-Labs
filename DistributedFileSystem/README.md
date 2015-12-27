# Distributed File System Project CS4032

## To start the distributed file system:
+ Linux/Mac: ./start.sh
+ Windows: run.bat

## Component Diagram:
![Diagram outlining the communication between each server of the file system](https://raw.githubusercontent.com/Conorbro/D.S.-Labs/master/DistributedFileSystem/Distributed%20File%20System.png)

### Distributed Transparent File Access

NFS style access model is used for this project. All clients interact with a client proxy server who's interface provides actions to READ, WRITE, and CLOSE files.

### Directory Service

The directory server keeps track of what file server each file is located on.
When a client requests to read or write to a file, the client proxy queries the directory server for the file server the file is located on.

### Lock Service

The lock server holds a mutex lock for each file held at either file server 1 or 2.
When a client accesses a file, the client proxy first asks the lock server if the file is locked and either continues with the client request or informs the client that the file is currently locked by another client.
A file is locked when a client writes to a file and is closed when the CLOSE command is sent by the client. Only the client that had previously locked the file may unlock it.

### Replication

File server 1's files are all written back to a replica server after every write by a client.
If file server 1 dies, the replica server takes its place and clients can perform requests as usual.
This can be tested by killing the file server 1 terminal after launching the distributed file system.
