# CanyonBomber
FPGA implementation by james10952001 of Canyon Bomber arcade game released by Kee Games in 1978
Port to MiSTer by Alan Steremberg

# Keyboard inputs :
```
   F1          : Coin + Start 1P
   F2          : Coin + Start 2P
   ctrl, space : Fire

   MAME/IPAC/JPAC Style Keyboard inputs:
     5           : Coin 1
     6           : Coin 2
     1           : Start 1 Player
     2           : Start 2 Players
     A           : Player 2 Fire


 Joystick support. (Converts the digital joystick to a simulated quadrature encoding)
```


Initial release:
-- There is still some cleanup of the code that can be done and a minor bug where occasionally there is a small glitch in the motion object as a ship hits the edge of the screen. I am not abslutely certain at this time that this is specific to the FPGA version and not a bug in the original hardware or code. 

# ROMs
```
                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip

```

