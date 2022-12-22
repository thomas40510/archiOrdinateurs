# Projet 'mini-MIPS'

Projet réalisé par [Thomas PRÉVOST](https://github.com/thomas40510) (CSN 2024) dans le cadre du cours d'architecture des ordinateurs au semestre 3 à l'ENSTA Bretagne. 

## Introduction
L'objectif de ce projet était l'implémentation d'une version simplifié de l'architecture MIPS dans l'objectif d'appréhender les concepts de base de l'architecture des ordinateurs.

Dans ce but, ont été implémentés une machine virtuelle (VM) et un assembleur.

## Machine virtuelle
La machine virtuelle est implémentée en langage `C`. Elle est capable de lire un fichier binaire contenant un programme écrit en assembleur et de l'exécuter.

Elle se trouve dans le répertoire `vm/`.

### Usage
Pour compiler la machine virtuelle, on utilise `gcc`:
```bash
gcc -o vm vm.c
```

Ensuite, l'exécution se fait en passant le chemin vers un fichier binaire en argument:
```bash
./vm <path_to_binary_file>
```

## Assembleur
L'assembleur a été écrit en langage `Ruby`, ce qui m'a donné l'opportunité de finir mon apprentissage de ce langage.
Il est capable de lire un fichier contenant un programme écrit en assembleur et de le compiler en un fichier binaire.

Il se trouve dans le répertoire `assembler/`.

Pour l'utiliser, il suffit de lancer le script `assembler.rb` en passant le chemin vers un fichier contenant un programme écrit en assembleur, et le fichier de sortie en argument:
```bash
ruby assembler.rb <path_to_assembly_file> <path_to_output_file>
```

Si jamais un module n'est pas installé, il suffit de l'installer avec `gem`:
```bash
gem install <module_name>
```

## Exemples
Plusieurs exemples de fichiers sont fournis pour tester le bon fonctionnement de l'assembleur et de la machine virtuelle.

Pour l'assembleur, nous disposons dans le répertoire `assembler/examples-asm/` de fichiers contenant des programmes écrits en assembleur. Ils sont les suivants :
- `12.asm`, programme qui affiche les nombres de 1 à 12
- `fibo.asm`, programme calculant le n-ième nombre de Fibonacci (en demandant `n` à l'utilisateur)
- `matrix_3x3.asm`, programme qui calcule le carré d'une matrice 3x3
- `test_asm.asm`, fichier contenant un panel d'instructions pour tester le bon fonctionnement de l'assembleur.

Pour la machine virtuelle, nous disposons dans le répertoire `vm/examples-bin/` de fichiers contenant des programmes compilés en binaire. Ils sont les suivants :
- `12.bin`, programme qui affiche les nombres de 1 à 12
- `facto.bin` calculant la factorielle d'un nombre entré par l'utilisateur
- `fibo.bin`, programme calculant le n-ième nombre de Fibonacci (en demandant `n` à l'utilisateur)