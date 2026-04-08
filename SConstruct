from SCons.Script import *

import os.path
import glob
import winreg
import urllib.request
import os
import shutil
import zipfile
import json
import subprocess

try:
    from SCons.Util import flatten as _scons_flatten
except Exception:
    def _scons_flatten(x):
        return x if isinstance(x, (list, tuple)) else [x]

env = Environment(tools=[])

# Utility functions

def allFilesIn(path):
    return [s.replace("$", "$$") for s in glob.glob(path + '/**/*', recursive=True) if os.path.isfile(s)]

def getSettings():
    with open("tools/build.json") as file:
        s = json.load(file)
    local_path = os.path.join("tools", "build.local.json")
    if os.path.isfile(local_path):
        with open(local_path) as file:
            s.update(json.load(file))
    return s

def targetDefinition(target, description):
    return env.Help(f"\n{target.ljust(20)}\t - {description}")

def isJunction(path):
    process = subprocess.run(["fsutil", "reparsepoint", "query", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return process.returncode == 0

# Useful paths
def a3toolsPath():
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"SOFTWARE\Bohemia Interactive\Arma 3 Tools") as key:
        return winreg.QueryValueEx(key, "path")[0]

def arma3Path():
    reg = winreg.ConnectRegistry(None, winreg.HKEY_LOCAL_MACHINE)
    with winreg.OpenKey(reg, r"SOFTWARE\Wow6432Node\bohemia interactive\arma 3") as key:
        return winreg.EnumValue(key,1)[1]

def addonBuilderPath():
    return os.path.join(a3toolsPath(), "AddonBuilder", "AddonBuilder.exe")

class Object(object):
    pass

def getPboInfo(settings):
    def addInfo(name):
        pboInfo = Object()
        pboInfo.name = name
        pboInfo.folder = os.path.join(settings["addonsFolder"], name)
        pboInfo.outputPath = pboInfo.folder + ".pbo"
        with open(os.path.join(pboInfo.folder,"$PBOPREFIX$"), "r") as file:
            pboInfo.pboPrefix = file.readline().strip()
        try:
            pboInfo.a3symlink = os.path.join("P:",pboInfo.pboPrefix)
        except:
            pboInfo.a3symlink = None

        pboInfo.buildSymlink = os.path.join("build",pboInfo.pboPrefix)

        if (name in settings["excludePboSymlinks"]):
            pboInfo.a3symlink = None
        return pboInfo
    return list(map(addInfo,filter(lambda x: os.path.isdir(os.path.join(settings["addonsFolder"], x)), os.listdir(settings["addonsFolder"]))))

def removeSymlink(pathTo):
    if pathTo is None:
        return []
    commands = []
    if isJunction(pathTo):
        commands.append(f'fsutil reparsepoint delete \"{pathTo}\"')
    if os.path.isdir(pathTo):
        commands.append(Delete(pathTo))
    return commands

def buildSymlink(pathFrom, pathTo):
    if pathTo is None:
        return []
    commands = removeSymlink(pathTo)
    if not os.path.isdir(os.path.dirname(pathTo)):
        commands.append(Mkdir(os.path.dirname(pathTo)))
    pathFromAbs = os.path.abspath(pathFrom)
    commands.append(f'mklink /J "{pathTo}" "{pathFromAbs}"')
    return commands

def clean_mod_staging_action(target, source, env):
    """Remove the whole @ mod folder (parent of outputFolder) so each build starts clean."""
    mod_root = env["MOD_ROOT_FOLDER"]
    if os.path.isdir(mod_root):
        try:
            shutil.rmtree(mod_root)
        except OSError as ex:
            print("clean_mod_staging:", ex)
    tdir = os.path.dirname(os.path.abspath(str(target[0])))
    if tdir:
        os.makedirs(tdir, exist_ok=True)
    with open(str(target[0]), "w", encoding="ascii") as f:
        f.write("ok\n")
    return None


def sync_mod_root_files(settings):
    """Copy mod.cpp, meta.cpp, mod_art/*.paa only, keys/ into the staged @ mod folder (next to addons/)."""
    addons_dir = os.path.abspath(settings["outputFolder"])
    mod_root = os.path.dirname(addons_dir)
    os.makedirs(addons_dir, exist_ok=True)
    os.makedirs(mod_root, exist_ok=True)

    for name in ["mod.cpp", "meta.cpp"]:
        src = os.path.abspath(name)
        if os.path.isfile(src):
            shutil.copy2(src, os.path.join(mod_root, name))

    art_src = os.path.abspath("mod_art")
    art_dst = os.path.join(mod_root, "mod_art")
    if os.path.isdir(art_src):
        if os.path.isdir(art_dst):
            shutil.rmtree(art_dst)
        paas = sorted(glob.glob(os.path.join(art_src, "**", "*.paa"), recursive=True))
        paas = [p for p in paas if os.path.isfile(p)]
        if paas:
            for paa in paas:
                rel = os.path.relpath(paa, art_src)
                dst_path = os.path.join(art_dst, rel)
                os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                shutil.copy2(paa, dst_path)

    keys_rel = settings.get("keysFolder", "keys")
    keys_src = os.path.abspath(keys_rel)
    keys_dst = os.path.join(mod_root, "keys")
    if os.path.isdir(keys_src):
        if os.path.isdir(keys_dst):
            shutil.rmtree(keys_dst)
        shutil.copytree(keys_src, keys_dst)


def modArtPaaFiles():
    """Paths under mod_art matching *.paa (recursive), for SCons $ escaping."""
    if not os.path.isdir("mod_art"):
        return []
    return [s.replace("$", "$$") for s in glob.glob(os.path.join("mod_art", "**", "*.paa"), recursive=True) if os.path.isfile(s)]


def stage_mod_action(target, source, env):
    sync_mod_root_files(env["PKG_SETTINGS"])
    tdir = os.path.dirname(os.path.abspath(str(target[0])))
    if tdir:
        os.makedirs(tdir, exist_ok=True)
    with open(str(target[0]), "w", encoding="ascii") as f:
        f.write("ok\n")
    return None


def buildPbo(settings, env, pbo):
    optBinarize = "-binarize=C:\\Windows\\System32\\print.exe" if pbo.name in settings["noBinarize"] else ""
    cfgConvertArg = "-cfgconvert=asdfafds" # + a3toolsPath() + "\\CfgConvert\\CfgConvert.exe"
    env.Command(pbo.outputPath, allFilesIn(pbo.folder)+["build"],
        f'"{addonBuilderPath()}" "{os.path.abspath(pbo.buildSymlink)}" "{os.path.abspath(settings["outputFolder"])}" "-project=build" "-prefix={pbo.pboPrefix}" -include=tools\\buildExtIncludes.txt {optBinarize}')
    targetDefinition(pbo.name, f"Build the {pbo.name} pbo.")
    return env.Alias(pbo.name, pbo.outputPath)

def downloadNaturaldocs(target, source, env):
    url = "https://www.naturaldocs.org/download/natural_docs/2.1.1/Natural_Docs_2.1.1.zip"
    zipFilePath = r"buildTools\NaturalDocs.zip"
    urllib.request.urlretrieve(url, zipFilePath)
    with zipfile.ZipFile(zipFilePath, 'r') as zip_ref:
        zip_ref.extractall(r"buildTools")

settings = getSettings()
pbos = getPboInfo(settings)

# Wipe staged @ mod folder once per scons invocation, before the DAG runs.
# Using AlwaysBuild() on a clean target made SCons re-run clean after stage_mod and deleted mod.cpp / mod_art / keys.
def _should_skip_startup_mod_wipe():
    try:
        from SCons.Script import GetOption as _GO
        return bool(_GO("help") or _GO("clean") or _GO("query"))
    except Exception:
        return False

if not _should_skip_startup_mod_wipe():
    _mod_root = os.path.dirname(os.path.abspath(settings["outputFolder"]))
    if os.path.isdir(_mod_root):
        try:
            shutil.rmtree(_mod_root)
        except OSError as ex:
            print("startup_wipe_mod_staging:", ex)
    # Force stage_mod / package to run; otherwise stale dist/*.stamp skips sync after wipe.
    for _stamp in [
        os.path.join("dist", "mod_staged.stamp"),
        os.path.join("dist", "package.stamp"),
    ]:
        if os.path.isfile(_stamp):
            try:
                os.remove(_stamp)
            except OSError as ex:
                print("startup_remove_stamp:", _stamp, ex)

env["MOD_ROOT_FOLDER"] = os.path.dirname(os.path.abspath(settings["outputFolder"]))
env["PKG_SETTINGS"] = settings

clean_mod_manual_stamp = os.path.join("dist", "manual_mod_staging_clean.stamp")
clean_mod_manual = env.Command(
    clean_mod_manual_stamp,
    [],
    Action(clean_mod_staging_action, "Cleaning @ mod staging folder..."),
)
env.Alias("clean_mod_staging", clean_mod_manual)
targetDefinition("clean_mod_staging", "Delete entire @ mod folder (manual target; normal builds wipe at startup).")

pboAliases = [buildPbo(settings, env, pbo) for pbo in pbos]

env.Command("buildTools", [], Mkdir("buildTools"))

copyIncludeSteps = [Copy("build", "include")] if os.path.isdir("include") else [Mkdir("build")]

buildDir = env.Command("build", allFilesIn("include"), copyIncludeSteps + sum(map(lambda pbo: buildSymlink(pbo.folder, pbo.buildSymlink),pbos),[]))

env.Command(r"buildTools\Natural Docs", [], [downloadNaturaldocs, Delete(r"buildTools\NaturalDocs.zip")])

mod_art_paa = modArtPaaFiles()
keys_folder = settings.get("keysFolder", "keys")
keys_files = allFilesIn(keys_folder) if os.path.isdir(keys_folder) else []
package_sources = [f for f in ["mod.cpp", "meta.cpp"] if os.path.isfile(f)]
package_sources.extend(mod_art_paa)
package_sources.extend(keys_files)

stage_mod_stamp = os.path.join("dist", "mod_staged.stamp")
stage_mod = env.Command(
    stage_mod_stamp,
    package_sources,
    Action(stage_mod_action, "Sync mod.cpp, meta.cpp, mod_art, keys to @ mod folder..."),
)
_stage_targets = stage_mod if isinstance(stage_mod, (list, tuple)) else [stage_mod]
for _st in _stage_targets:
    for _pa in pboAliases:
        env.Depends(_st, _pa)

def package_action(target, source, env):
    """Sign PBOs in addons (staging is done by stage_mod / all)."""
    settings = env["PKG_SETTINGS"]
    dssign_exe = env.get("DSSIGNFILE_EXE")
    addons_dir = os.path.abspath(settings["outputFolder"])

    key_raw = settings.get("signPrivateKey") or os.environ.get("GLT_TRIALS_BIPRIVATEKEY", "")
    key_path = key_raw.strip() if isinstance(key_raw, str) else ""
    if key_path:
        key_path = os.path.normpath(os.path.expanduser(os.path.expandvars(key_path)))
        if not os.path.isabs(key_path):
            key_path = os.path.abspath(key_path)
    if key_path and os.path.isfile(key_path):
        if not dssign_exe or not os.path.isfile(dssign_exe):
            print("package: DSSignFile.exe not found (install Arma 3 Tools); skipped signing")
        else:
            for pbo in sorted(glob.glob(os.path.join(addons_dir, "*.pbo"))):
                print("package: signing", pbo)
                subprocess.run([dssign_exe, key_path, pbo], check=True)
    elif key_path:
        print("package: signPrivateKey path not found; skipped signing")
    else:
        print("package: no signPrivateKey (tools/build.local.json or GLT_TRIALS_BIPRIVATEKEY); skipped signing")

    tdir = os.path.dirname(os.path.abspath(str(target[0])))
    if tdir:
        os.makedirs(tdir, exist_ok=True)
    with open(str(target[0]), "w", encoding="ascii") as f:
        f.write("ok\n")
    return None

def _resolve_dssign_exe():
    try:
        p = os.path.join(a3toolsPath(), "DSSignFile", "DSSignFile.exe")
        if os.path.isfile(p):
            return p
    except Exception:
        pass
    steam = os.path.join(
        os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)"),
        "Steam", "steamapps", "common", "Arma 3 Tools", "DSSignFile", "DSSignFile.exe",
    )
    if os.path.isfile(steam):
        return steam
    return None

dssign_exe = _resolve_dssign_exe()
env["DSSIGNFILE_EXE"] = dssign_exe

package_stamp = os.path.join("dist", "package.stamp")
pkg = env.Command(package_stamp, package_sources, Action(package_action, "Sign PBOs in staged addons..."))
# Signing must run after staged PBOs exist; also depend on each PBO alias so addon-only edits still resign.
_pkg_nodes = _scons_flatten(pkg)
for _pn in _pkg_nodes:
    for _st in _stage_targets:
        env.Depends(_pn, _st)
    for _pa in pboAliases:
        env.Depends(_pn, _pa)
# SCons often skips package.stamp when only Depends() links to the graph; force the sign action whenever "all" builds.
env.AlwaysBuild(pkg)

allPbos = env.Alias("all", pboAliases + [stage_mod, pkg])
targetDefinition("all", "Build all pbos, stage @ mod folder, then sign PBOs if key is set.")
env.Alias("package", pkg)
targetDefinition("package", "Sign PBOs (same as signing step in default 'all' build).")

buildDocs = env.Command(r"docs\index.html",
    [s for s in allFilesIn(settings["addonsFolder"]) if s.endswith(".sqf")] + [r"buildTools\Natural Docs"], 
    [Mkdir("docs"), r'"buildTools\Natural Docs\NaturalDocs.exe" naturaldocs'])
env.AlwaysBuild(buildDocs)

env.Alias("docs", r"docs\index.html")
targetDefinition("docs", "Generate naturaldocs documentation")
env.Help("\n")

if GetOption('clean'):
    env.Execute(sum(map(lambda pbo: removeSymlink(pbo.buildSymlink), pbos),[]))
env.Clean(["build", "all"], r"build")
env.Clean(["package"], r"dist")
env.Clean(["buildTools", "all"], r"buildTools")
env.Clean(["docs", "all"], ["docs", r"naturaldocs\Working Data"])

try:
    settings = getSettings()
    a3dir = arma3Path()
    symlinks = env.Alias("symlinks", [], sum(map(lambda pbo: buildSymlink(pbo.folder, pbo.a3symlink), pbos),[]))
    env.AlwaysBuild(symlinks)

    removeSymlinks = env.Alias("rmsymlinks", [], sum(map(lambda pbo: removeSymlink(pbo.a3symlink), pbos),[]))
    env.AlwaysBuild(removeSymlinks)
except Exception as e:
    print(e)
    print("Error: Couldn't find arma 3, cannot make or remove symlinks")

env.Default("all")