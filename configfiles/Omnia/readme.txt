Flashing the Turris Omnia
-------------------------

From factory to ROOter

- Copy the ROOter 'upgrade.img.gz' file and the 'omnia-medkit-turris-omnia-initramfs.tar.gz' file to the root of a
USB flash drive formatted with FAT32. This must be less than 16Gb in size.

- Disconnect other USB devices from the Omnia and connect the flash drive to either USB port.

- Power on the Omnia while holding down the rear reset button and hold it until 4 LEDs are
illuminated, then release.

- Wait approximately 2 minutes for the Turris Omnia to flash itself with the temporary image, 
during which time the LEDs will change multiple times.

- Connect a computer to a LAN port of the Turris Omnia.

- Use your browser to go to 192.168.1.1 and the ROOter GUI.

- Go to "System->Backup/Flash Firmware" and flash the ROOter "upgrade.img.gz" 
file to complete the flash procedure. This must be done as the previous flash is
only temporary.