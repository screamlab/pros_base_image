# PROS Base Image
This is the base docker image of PROS system. All right reserved.



## Scheduled GitHub Action CI

The GitHub Action has been set to run at 00:00 on the first of every month. This can help us to keep updating from the base image `ros:humble-ros-core-jammy`.

The tag of the Docker image has 2 formats:

- 0.0.0
  - This is triggered by adding new tag manually.
- 0.0.0-20241001
  - This is triggered by `cron` which is set in the `yaml` file.



## System Architecture

The system architecture is shown in the [LucidChart](https://lucid.app/lucidchart/521741b7-d1f5-44d3-a668-399a7c6a1aa1/edit?viewport_loc=-419%2C31%2C2560%2C1306%2CHWEp-vi-RSFO&invitationId=inv_5adc6c69-ef18-4193-9fe0-5a488a745e8c).



## Shortcut

- `r`: Do `colcon build` and `source` the `setup.bash` in the `/workspaces` folder.
- `b`: launch ros bridge server
- `m`: `make -j`



## Colcon

We've written a run command `rebuild_colcon.rc` in `/workspaces` folder. You can do `colcon build` and `source /workspaces/install/setup.bash` by the following command:

```bash
source /workspaces/rebuild_colcon.rc
```



### <font color=#FF0000>Shortcut</font> for Colcon

We have written the command `source /workspaces/rebuild_colcon.rc` as an alias <font color=#FF0000>'r'</font> in both `/root/.bashrc` and `/root/.zshrc`. Users only need to <font color=#FF0000>type 'r' to execute the command</font>.



## Manually build the image

### Environments Setup

1. To use buildx, make sure your Docker runtime is at least version 19.03. buildx actually comes bundled with Docker by default, but needs to be enabled by setting the environment variable DOCKER_CLI_EXPERIMENTAL.

   ```bash
   export DOCKER_CLI_EXPERIMENTAL=enabled
   ```

2. If you're on Linux, you need to set up `binfmt_misc`. This is pretty easy in most distributions but is even easier now that you can just run a privileged Docker container to set it up for you.

   ```bash
   docker run --rm --privileged tonistiigi/binfmt:latest
   ```

   or

    ```bash
   docker run --rm --privileged docker/binfmt:latest
    ```

3. Create a new builder which gives access to the new multi-architecture features. This command creates a new builder instance. In this case, it supports both linux/arm64 and linux/amd64 platforms. The --name flag sets a name for the builder- "multi-platform-builder".

   ```bash
   docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder
   ```

4. This command inspects the builder created in the previous step and performs any necessary setup or configuration. The --bootstrap flag indicates that the builder should be initialized if it hasn't been already

   ```bash
   docker buildx inspect --bootstrap
   ```

5. This command builds a Docker image using the builder created earlier.

   ```bash
   docker buildx build --platform=linux/arm64,linux/amd64 --push --tag ghcr.io/otischung/pros_ai_image:latest -f ./Dockerfile .
   ```


Reference: https://stackoverflow.com/questions/70757791/build-linux-arm64-docker-image-on-linux-amd64-host

Reference: https://unix.stackexchange.com/questions/748633/error-multiple-platforms-feature-is-currently-not-supported-for-docker-driver



### Troubleshooting

If you encounter that you can't build Dockerfile for arm64 due to `libc-bin` segmentation fault, try solve by the following instrucitons.

```bash
docker pull tonistiigi/binfmt:latest
docker run --privileged --rm tonistiigi/binfmt --uninstall qemu-*
docker run --privileged --rm tonistiigi/binfmt --install all)
```

Reference: https://askubuntu.com/questions/1339558/cant-build-dockerfile-for-arm64-due-to-libc-bin-segmentation-fault

