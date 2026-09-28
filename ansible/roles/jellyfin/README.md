# jellyfin role

Runs Jellyfin as a container with NVIDIA (NVENC) hardware transcoding, deployed via docker compose.
Standalone by design, so it can move to a dedicated media box or a private repo later.

This role only *prepares* the setup.
Starting the container is a deliberate step, because it conflicts with a bare-metal Jellyfin on port 8096 and the shared data dir.

## Layout

Everything lives under `jellyfin_home` (default `~/dev/tools/jellyfin`), matching the homeassistant setup.

```
~/dev/tools/jellyfin/
  docker-compose.yaml      # templated by the role
  config/                  # -> container /config  (data dir)
  config/config/           # -> container /config/config (Jellyfin XML config)
  cache/                   # -> container /cache
```

The official `jellyfin/jellyfin` image uses `/config` as the data dir and `/config/config` for the XML config.
Verify before migrating:

```
docker inspect jellyfin/jellyfin:latest --format '{{range .Config.Env}}{{println .}}{{end}}' | grep JELLYFIN
```

## Prerequisites

- Docker with the compose plugin (installed by the `polymath-dev` role).
- NVIDIA driver on the host, plus `nvidia-container-toolkit` with the docker `nvidia` runtime registered in `/etc/docker/daemon.json`.
  Already present on the current host.
  On a fresh box, install the toolkit and run `sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker`.
- The `community.docker` collection (in `requirements.yml`) if you enable the compose deploy task.

## Configuration

Set these in a playbook or inventory, or edit `docker-compose.yaml` after it is generated:

- `jellyfin_media_mounts` — replace the `/PATH_TO_YOUR_MEDIA:/media` placeholder with your real library path(s).
- `jellyfin_uid` / `jellyfin_gid` — the host user the container runs as, for data and media access.
- `jellyfin_render_gid` / `jellyfin_video_gid` — GPU device groups.

## First run (migrating from the bare-metal install)

The bare-metal install stays in place until you deliberately cut over.

1. Prepare the files (no container is started):

   ```
   ansible-playbook -i localhost, -c local -K <playbook-with-jellyfin-role>.yml
   ```

2. Copy the existing data in (non-destructive, leaves originals untouched):

   ```
   ansible/roles/jellyfin/files/migrate-data.sh
   ```

3. Set your media path in `~/dev/tools/jellyfin/docker-compose.yaml`.

4. Stop the bare-metal service so it stops using port 8096 and the data dir:

   ```
   sudo systemctl stop jellyfin
   sudo systemctl mask jellyfin
   ```

5. Start the container:

   ```
   cd ~/dev/tools/jellyfin && docker compose up -d
   ```

6. Verify hardware transcoding: play a file that forces a transcode and watch `nvidia-smi` for an `ffmpeg` process.

Once you trust the container, uncomment the `Start Jellyfin` task in `tasks/main.yml` to have converge manage it.

## Fresh install (no migration)

Skip the migration step. The role seeds `encoding.xml` with the NVENC settings on first run.
Add libraries and users through the web UI at `http://<host>:8096`.
