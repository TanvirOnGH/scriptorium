#!/usr/bin/env python
# Check installed packages using linux-info.eclass for necessary kernel options

import signal
from portage.util import ensure_dirs
from portage.package.ebuild.doebuild import doebuild
from portage import dbapi, catsplit, config


def debug_signal(_signum, _frame):
    import pdb

    pdb.set_trace()


signal.signal(signal.SIGUSR1, debug_signal)

vartree = dbapi.get("vartree")
settings = config()

for cpv in vartree.cpv_all():
    inherit = vartree.aux_get(cpv, ["INHERITED"])[0]
    if "linux-info" in inherit:
        pv = catsplit(cpv)[1]
        cpvpath = f"{vartree.getpath(cpv)}/{pv}.ebuild"
        print(f"Checking: {cpv}", flush=True)
        ensure_dirs(cpvpath)
        for phase in ["clean", "setup"]:
            doebuild(cpvpath, phase, settings=settings, tree="vartree", vartree=vartree)
        print(f"Finished: {cpv}", flush=True)
