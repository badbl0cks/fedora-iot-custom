#!/bin/sh

set -oex pipefail
set +u

dnf groupinstall "C Development Tools and Libraries" "Development Tools"
