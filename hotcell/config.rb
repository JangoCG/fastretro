# The client timeout covers the deadline, queue wait and reply.
HotCell.limits concurrency: 2,
               queue_size: 4,
               queue_wait: 10,
               deadline: 30,
               memory: 1280 * 1024**2,
               file_size: 48 * 1024**2
