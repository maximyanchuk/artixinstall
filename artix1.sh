#!/bin/bash

# Artix Linux installation
# Скрипт быстрой базовой установки Artix Linux runit
# Основан на Artix Wiki 21.04.2021
# Цель скрипта - быстрое развертывание системы

clear

echo "Начинаем установку Artix Linux"
date +"%D"
date +"%T"
echo "loadkeys ru, setfont cyr-sun16"
loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true
date +"%D"
date +"%T"

echo "РАЗБИВКА ДИСКА /ВНИМАНИЕ ВСЕ ДАННЫЕ БУДУТ УНИЧТОЖЕНЫ/"
echo "y = Legasy BIOS"
echo "n = UEFI (пока не реализовано)"
echo -n "Произвести разбивку диска в режиме BIOS? (y/n) "
read item
case "$item" in
    y|Y) echo "Ввели «y», продолжаем..."
		with_bios
        ;;
    n|N) echo "Ввели «n», продолжаем..."
        with_uefi
        ;;
    *) echo "Ничего не ввели. Тогда... Создаем разделы в режиме BIOS"
        ;;
esac

echo 'Разметка диска'
fdisk -l
pauza

echo "Установка базовой системы с runit"
echo -e "base\tbase-devel\trunit\telogind-runit"
basestrap /mnt base base-devel runit elogind-runit

echo "Установка ядра"
echo -e "linux\tlinux-firmware"
basestrap /mnt linux linux-firmware
#long term spport kernel
#basestrap /mnt linux-lts linux-firmware

echo "Установка доп. софта"
basestrap /mnt vim nano mc

echo "Настройка системы"
fstabgen -U /mnt >> /mnt/etc/fstab

artix-chroot /mnt # formerly artools-chroot
#artix-chroot /mnt sh -c "$(curl -fsSL git.io/myscript.sh)"

#functions
function with_bios {
	echo "Создаем разделы в режиме BIOS"
	(
		echo o;
		echo n;
		echo;
		echo;
		echo;
		echo +100M;
		
		echo n;
		echo;
		echo;
		echo;
		echo +30G;

		echo n;
		echo;
		echo;
		echo;
		echo +1024M;

		echo n;
		echo p;
		echo;
		echo;
		echo a;
		echo 1;

		echo w;
	) | fdisk /dev/sda

	echo 'Форматирование дисков'
	mkfs.ext2 /dev/sda1 -L boot
	mkfs.ext4 /dev/sda2 -L root
	mkswap /dev/sda3 -L swap
	mkfs.ext4 /dev/sda4 -L home

	echo 'Монтирование дисков'
	mount /dev/sda2 /mnt
	mkdir /mnt/{boot,home}
	mount /dev/sda1 /mnt/boot
	swapon /dev/sda3
	mount /dev/sda4 /mnt/home
}

function with_uefi {
echo "Создаем разделы в режиме UEFI"
	(
		echo o;
		echo n;
		echo;
		echo;
		echo;
		echo +1G;
		
		echo n;
		echo;
		echo;
		echo;
		echo +30G;

		echo n;
		echo;
		echo;
		echo;
		echo +1024M;

		echo n;
		echo p;
		echo;
		echo;
		echo a;
		echo 1;

		echo w;
	) | fdisk /dev/sda

	echo 'Форматирование дисков'
	mkfs.fat -F 32 /dev/sda1 -L boot
	mkfs.ext4 /dev/sda2 -L root
	mkswap /dev/sda3 -L swap
	mkfs.ext4 /dev/sda4 -L home

	echo 'Монтирование дисков'
	mount /dev/sda2 /mnt
	mkdir /mnt/{boot,home}
	mount /dev/sda1 /mnt/boot
	swapon /dev/sda3
	mount /dev/sda4 /mnt/home
}

function pauza {
	sec=5
	echo "Установака продожится через:"
	while [ $sec -gt 0 ]
	do
	sleep 1s
	#clear
	echo -n "$sec"
	sec=$(( $sec - 1 ))
	done
 }