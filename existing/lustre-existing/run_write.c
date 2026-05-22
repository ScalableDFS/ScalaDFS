#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(void) {
    const char *path = "/mnt/client/a.txt";
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        fprintf(stderr, "Failed to open %s: %s\n", path, strerror(errno));
        return EXIT_FAILURE;
    }

    size_t buf_size = 4000;
    char *buf = malloc(buf_size);
    if (!buf) {
        fprintf(stderr, "Failed to allocate buffer: %s\n", strerror(errno));
        close(fd);
        return EXIT_FAILURE;
    }

    memset(buf, 'A', buf_size);

    ssize_t written = write(fd, buf, buf_size);
    if (written == -1) {
        fprintf(stderr, "Failed to write to %s: %s\n", path, strerror(errno));
        free(buf);
        close(fd);
        return EXIT_FAILURE;
    } else if ((size_t)written < buf_size) {
        fprintf(stderr, "Partial write: wrote %zd of %zu bytes\n", written, buf_size);
    }

    free(buf);

    if (close(fd) == -1) {
        fprintf(stderr, "Failed to close %s: %s\n", path, strerror(errno));
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

