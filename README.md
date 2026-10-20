# wordcraft-test

A small Docker setup for running [WordCraft](https://github.com/storytold/wordcraft)'s command-line tool to convert .docx files to PDF, so you can see how it handles your documents.

WordCraft is alpha-stage open-source software. It came out when I really needed it and this was my chance to test it and use it on some of my personal projects. This is for anyone who want to try it's docx to pdf coversion from the CLI, a little project to have fun.

## What's included

- `Dockerfile`: builds an image with the WordCraft Linux release (`wordcraft-cli`) and poppler-utils (`pdfinfo`, `pdffonts`) for checking results.
- `corpus/`: put the .docx files you want to convert here. Ignored by git.
- `out/`: converted PDFs are written here. Ignored by git.

## Requirements

- Docker (Docker Desktop on Windows and macOS, Docker Engine on Linux)
- Internet access during the build, to download the WordCraft release from GitHub
- A terminal: PowerShell or Command Prompt on Windows (Git Bash also works, see below), Terminal on macOS, any shell on Linux

## Setup

1. Download or clone this project and open a terminal in its folder.
2. Create the working folders:

   ```
   mkdir corpus
   mkdir out
   ```

3. Build the image:

   ```
   docker build -t wordcraft-test .
   ```

4. Check that the CLI runs:

   ```
   docker run --rm wordcraft-test --help
   ```

### Choosing a WordCraft version

The version is set by the `WC_VERSION` argument in the `Dockerfile`. Check the [releases page](https://github.com/storytold/wordcraft/releases) for the current version. To build a specific version without editing the file:

```
docker build --build-arg WC_VERSION=0.3.0 -t wordcraft-test .
```

## Converting a document

Copy your .docx file into `corpus/`, then run the conversion. The output appears in `out/`.

Replace `report.docx` with your filename in every command below. Keep the filename simple (no spaces) to avoid quoting issues.

### Windows

**PowerShell**

```powershell
docker run --rm -v "${PWD}/corpus:/in:ro" -v "${PWD}/out:/out" wordcraft-test convert /in/report.docx /out/report-wc.pdf
```

**Command Prompt**

```cmd
docker run --rm -v "%cd%/corpus:/in:ro" -v "%cd%/out:/out" wordcraft-test convert /in/report.docx /out/report-wc.pdf
```

**Git Bash**

Git Bash rewrites paths that begin with `/`, which breaks the container paths. Disable that rewriting for the command:

```bash
MSYS_NO_PATHCONV=1 docker run --rm -v "$PWD/corpus:/in:ro" -v "$PWD/out:/out" wordcraft-test convert /in/report.docx /out/report-wc.pdf
```

### Linux

```bash
docker run --rm -v "$PWD/corpus:/in:ro" -v "$PWD/out:/out" wordcraft-test convert /in/report.docx /out/report-wc.pdf
```

### macOS

> **Note:** I personally have not run these commands on macOS. They use the same Docker syntax as Linux and should work, but if you run into problems please open an issue.

```bash
docker run --rm -v "$PWD/corpus:/in:ro" -v "$PWD/out:/out" wordcraft-test convert /in/report.docx /out/report-wc.pdf
```

On Apple Silicon Macs the image is x86_64, so Docker runs it under emulation. This works but is slower. You can request the platform explicitly when building:

```bash
docker build --platform linux/amd64 -t wordcraft-test .
```

## Converting a whole folder

Linux and macOS:

```bash
for f in corpus/*.docx; do
  name=$(basename "$f" .docx)
  timeout 120 docker run --rm -v "$PWD/corpus:/in:ro" -v "$PWD/out:/out" wordcraft-test convert "/in/$name.docx" "/out/$name-wc.pdf" \
    || echo "FAILED: $name"
done
```

Windows PowerShell:

```powershell
Get-ChildItem corpus\*.docx | ForEach-Object {
  $name = $_.BaseName
  docker run --rm -v "${PWD}/corpus:/in:ro" -v "${PWD}/out:/out" wordcraft-test convert "/in/$name.docx" "/out/$name-wc.pdf"
  if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $name" }
}
```

## Checking a result

Page count:

```
docker run --rm -v "${PWD}/out:/out" --entrypoint pdfinfo wordcraft-test /out/report-wc.pdf
```

Fonts embedded in the PDF:

```
docker run --rm -v "${PWD}/out:/out" --entrypoint pdffonts wordcraft-test /out/report-wc.pdf
```

On Linux and macOS use `$PWD` in place of `${PWD}`. On Command Prompt use `%cd%`. Git Bash users should add `MSYS_NO_PATHCONV=1` as above.

## Troubleshooting

- **`No such file or directory` inside the container (Git Bash):** path conversion is rewriting `/in/...`. Prefix the command with `MSYS_NO_PATHCONV=1`.
- **`mounts denied` or `path not shared` (Docker Desktop):** add the folder under Docker Desktop's file sharing settings, or move the project into your user folder, which is shared by default.
- **Download fails during `docker build`:** the release version may have changed. Check the releases page and pass a valid `WC_VERSION`.
- **Slow on Apple Silicon:** expected under emulation. Build with `--platform linux/amd64`.
- **Display or graphics error:** WordCraft's CLI is meant to run without a display, but this has not been verified everywhere. Note the exact error message if you see one.

## Git

The included `.gitignore` keeps documents and output out of version control:

```
corpus/
out/
```

## Licence

This project is provided as-is. WordCraft is licensed separately by its authors; see its repository for terms.
