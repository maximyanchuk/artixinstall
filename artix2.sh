#!/bin/bash

# Artix Linux installation
# Скрипт быстрой базовой установки Artix Linux runit
# Основан на Artix Wiki 21.04.2021
# Цель скрипта - быстрое развертывание системы

read -p "Введите hostname: " hostname
read -p "Введите username: " username

echo $hostname > /etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t${hostname}.localdomain\t${hostname}" >> /etc/hosts
 
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime

#Run hwclock to generate /etc/adjtime:
hwclock --systohc


echo "Добавляем русскую лоализацию"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 

echo "Обновим текущую локаль системы"
locale-gen

echo 'Указываем язык системы'
echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf

echo 'Вписываем KEYMAP=ru FONT=cyr-sun16'
echo 'KEYMAP=ru' >> /etc/vconsole.conf
echo 'FONT=cyr-sun16' >> /etc/vconsole.conf

pacman -Syy

echo "Устанавливаем загрузчик"
pacman -S grub os-prober
echo "bios или uefi?"
read -p "1 - bios, 0 - uefi: " bios_set
if [[ $bios_set == 0 ]]; then
	#for BIOS systems
	grub-install --recheck /dev/sda
elif [[ $bios_set == 1 ]]; then
	#for UEFI systems
	pacman -S efibootmgr
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
fi
grub-mkconfig -o /boot/grub/grub.cfg

echo 'Ставим сеть'
pacman -S dhcpcd networkmanager networkmanager-runit --noconfirm

echo 'Подключаем автозагрузку менеджера входа и интернет'
#ln -s /etc/runit/sv/NetworkManager /run/runit/runsvdir/service
ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/current

#echo "Ставим программу для Wi-fi"
#pacman -S dialog wpa_supplicant --noconfirm 
#pacman -S wifi-menu

echo "Добавляем пользователя"
useradd -m -g users -G wheel -s /bin/bash $username

echo "Создаем root пароль"
passwd

echo "Устанавливаем пароль пользователя"
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

#Install connman runit and optionally a front-end: connman-gtk or cmst for Qt-based DEs
pacman -S connman-runit connman-gtk
ln -s /etc/runit/sv/connmand /etc/runit/runsvdir/default

#echo 'Ставим шрифты'
#pacman -S ttf-liberation ttf-dejavu --noconfirm 

echo 'Установка завершена! Перезагрузите систему.'
exit