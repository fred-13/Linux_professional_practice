## Task
Write an nginx configuration that gives the client access only with a specific cookie.
If the client does not have it, you need to redirect to the location in which the cookie will be added, after which the client will be sent back (redirect) to the requested resource.

Meaning: smart bots rarely come across, stupid bots on redirects with cookies will not go twice.

## Solution
1. Run environment
    ```bash
    vagrant up
    ```

1. Check with curl
    ```bash
    # check that we are redirected when there is no cookie
    curl -I localhost:8080

    # check set cookie header
    curl -I --cookie 'originUrl=http://localhost:8080/otus.html' localhost:8080/secret

    # check response status with cookie
    curl -I --cookie "secret=supersecret" localhost:8080
    ```

1. Check with browser
    ```bash
    google-chrome http://localhost:8080/otus.html
    ```
