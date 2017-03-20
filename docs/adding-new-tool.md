# Adding New Tools

Suppose the new tool we're trying to add is *bwa v0.7.5a*.

## Creating Container Image

Create a directory `/bulid/containers/bwa/0.7.5a`.

Create a file named `Dockerfile`.

- Use the template as the basis.
- Make neccessary changes.
- Add `.dockerignore` to reduce context transfer to Docker daemon.

Create a file named `Singularity`.

- Use the template as the basis.
- Make necessary changes.

Add an entry to `/build/scripts/tools.json`

```json
{
    "programs": {
        ...
        "bwa": [
            "0.7.15",
            "0.7.12",
            "0.7.5a"
        ],
        ...
    },
    "containerDependency": {
        ...
        "bwa": [
            "cmo_bwa_mem"
        ],
        ...
    }
}
```

Make sure that `/build/cwl-wrappers/cmo_resources.json` has only the `default` key (no other versions) under the tool name (e.g. `bwa`). Set the path to where the tool binary is located inside the container. For example:

```
"bwa": {
    "default": "/usr/bin/bwa"
}
```

Make sure that `/build/cwl-wrappers/prism_resources.json` has the correct key/value mapping something like below under the tool name (e.g. `bwa`).

```
"bwa": {
    "0.7.12": "sing.sh bwa 0.7.12", 
    "0.7.15": "sing.sh bwa 0.7.15", 
    "0.7.5a": "sing.sh bwa 0.7.5a", 
    "default": "sing.sh bwa 0.7.5a"
}
```

Build a Docker image:

```bash
cd /vagrant/build/scripts/
./build-images.sh -t bwa:0.7.5a -d
```

Verify if you can run it:

```bash
sudo docker run -it bwa:0.7.5a
```

If everything looks good, rebulid a Docker image without the `-d` parameter this time. This will push the Docker image to Docker Hub, and then create a Singularity image based on it.

```bash
./build-images.sh -t bwa:0.7.5a
```

Verify if you can run the singularity container:

```bash
singularity run /vagrant/build/containers/bwa/0.7.5a/bwa.img
```

Verify if the bind points are properly built into the image:

```bash
singularity exec /vagrant/build/containers/bwa/0.7.5a/bwa.img ls /
```

## Creating CWL Wrapper

Create a directory `/bulid/cwl-wrapers/bwa/0.7.5a`.

Add the following files under the directory:

1. Add `metadata.yaml`.
1. Add `outputs.yaml`.
1. Add `requirements.yaml`.
1. Add `postprocess.py`.

Generate the CWL Wrapper:

```bash
./build-cwl.sh -t bwa:0.7.5a:cmo_bwa_mem
```
