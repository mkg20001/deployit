# VBoxManage createvm --name DevVM2 --ostype Windows7_64 --register
VBoxManage import devvm2.ova
DO_RUN=1 node gen.js windeploy
VBoxHeadless --startvm DevVM2 # will setup and shutdown after setup
VBoxManage snapshot DevVM2 take Setup

