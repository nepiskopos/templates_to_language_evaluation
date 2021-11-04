#!/usr/bin/env python3


import argparse
import shlex
import subprocess
import sys


def docker_installed():
    print("Checking if Docker is installed and configured on this system...")
    bashCommand = "which docker"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print("Docker is installed and configured on this system")
        result = True
    else:
        print("Docker is not installed and/or configured on this system")
    return result

def image_exists(name):
    print(f"Checking if {name} image exists...")
    bashCommand = "docker image list"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE)
    bashCommand = "grep " + name
    grep = subprocess.Popen(shlex.split(bashCommand), stdin=docker.stdout, stdout=subprocess.PIPE, encoding='utf-8')
    docker.stdout.close()
    output, error = grep.communicate()
    returncode = grep.returncode
    result = False
    if returncode == 0:
        print(f"{name} docker image exists!")
        result = True
    else:
        print(f"{name} docker image does not exist")
    return result

def build_image(name, path):
    print(f"Building {name} docker image using the Dockerfile...")
    bashCommand = f"docker build -t {name} -f {path}/docker/Dockerfile {path}"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully built {name} docker image using the Dockerfile!")
        result = True
    else:
        print(f"Building {name} docker image using the Dockerfile has failed")
    return result

def nvidia_gpu():
    print("Checking if an Nvidia GPU is available on this system...")
    bashCommand = "which nvidia-smi"
    nvidia = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    output, error = nvidia.communicate()
    returncode = nvidia.returncode
    result = False
    if returncode == 0:
        print("Nvidia GPU is available on this system!")
        result = True
    else:
        print("Nvidia GPU is not available on this system")
    return result

def nvidia_container_toolkit():
    print("Checking if Nvidia container toolkit is available on this system...")
    bashCommand = "which nvidia-container-toolkit"
    nvidia = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    output, error = nvidia.communicate()
    returncode = nvidia.returncode
    result = False
    if returncode == 0:
        print("Nvidia container toolkit is available on this system!")
        result = True
    else:
        print("Nvidia container toolkit is not available on this system")
    return result

def container_exists(name):
    print(f"Checking if {name} docker container exists...")
    bashCommand = "docker ps -a"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    bashCommand = "grep " + name
    grep = subprocess.Popen(shlex.split(bashCommand), stdin=docker.stdout, stdout=subprocess.PIPE, encoding='utf-8')
    docker.stdout.close()
    output, error = grep.communicate()
    returncode = grep.returncode
    result = False
    if returncode == 0:
        print(f"{name} docker container exists!")
        result = True
    else:
        print(f"{name} docker container does not exist")
    return result

def create_container(container, image):
    bashCommand = f"docker create --name {container} "
    print(f"Creating {container} using {image} image...")
    if nvidia_gpu():
        if nvidia_container_toolkit():
            bashCommand = bashCommand + f"--gpus all "
        else:
            bashCommand = bashCommand + f"--device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidia1:/dev/nvida1 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm "
    else:
        bashCommand = bashCommand + f"-it {image}"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"{container} container created!")
        result = True
    else:
        print(f"{container} container could not be created")
    return result

def container_active(name):
    print(f"Checking if {name} docker container is active...")
    bashCommand = "docker ps -a"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    bashCommand = "grep " + name
    grep = subprocess.Popen(shlex.split(bashCommand), stdin=docker.stdout, stdout=subprocess.PIPE, encoding='utf-8')
    docker.stdout.close()
    bashCommand = "grep Up"
    grepp = subprocess.Popen(shlex.split(bashCommand), stdin=grep.stdout, stdout=subprocess.PIPE, encoding='utf-8')
    grep.stdout.close()
    output, error = grepp.communicate()
    returncode = grepp.returncode
    result = False
    if returncode == 0:
        print(f"{name} docker container is active!")
        result = True
    else:
        print(f"{name} docker container is not active")
    return result

def activate_container(container):
    print(f"Activating {container} container...")
    bashCommand = f"docker start {container}"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=subprocess.PIPE, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"{container} container activated!")
        result = True
    else:
        print(f"{container} container could not be activated")
    return result

def train_tgen(container):
    print(f"Training TGen in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/tgen/tgen.sh -train'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully trained TGen!")
        result = True
    else:
        print(f"TGen training has failed")
    return result

def gen_tgen(container):
    print(f"Generating text using TGen in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/tgen/tgen.sh -gen'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully generated text using TGen!")
        result = True
    else:
        print(f"TGen text generation has failed")
    return result

def eval_tgen(container, t_format):
    print(f"Evaluating TGen's text generation in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/e2e-metrics/e2e_metrics_tgen.sh {t_format}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully evaluated TGen's text generation!")
        result = True
    else:
        print(f"TGen text generation evalutation has failed")
    return result

def train_ntg(container, data, ar, dec, gpu):
    print(f"Training NTG in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/neural-template-gen/ntg_{data}.sh -train {ar} {dec} {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully trained NTG!")
        result = True
    else:
        print(f"NTG's training has failed")
    return result

def seg_ntg(container, data, ar, dec, gpu):
    print(f"Creating Viterbi segmentations using NTG in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/neural-template-gen/ntg_{data}.sh -seg {ar} {dec} {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully created Viterbi segmentations using NTG!")
        result = True
    else:
        print(f"NTG Viterbi segmentations creation has failed")
    return result

def gen_ntg(container, data, ar, dec, gpu):
    print(f"Generating text using NTG in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/neural-template-gen/ntg_{data}.sh -gen {ar} {dec} {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully generated text using NTG!")
        result = True
    else:
        print(f"NTG text generation has failed")
    return result

def gen_ntg_original(container, data, ar, gpu):
    print(f"Generating text using NTG in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/neural-template-gen/ntg_{data}_original.sh {ar} {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully generated text using NTG!")
        result = True
    else:
        print(f"NTG text generation has failed")
    return result

def eval_ntg(container, data, ar, dec, t_format):
    print(f"Evaluating NTG's text generation in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/"
    if data == 'e2e':
        bashCommand = bashCommand + f"e2e-metrics/e2e_metrics_ntg.sh {ar} {dec} {t_format}'"
    else:
        bashCommand = ''
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully evaluated NTG's text generation!")
        result = True
    else:
        print(f"NTG's text generation evalutation has failed")
    return result

def eval_ntg_original(container, data, ar, t_format):
    print(f"Evaluating NTG's text generation in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/"
    if data == 'e2e':
        bashCommand = bashCommand + f"e2e-metrics/e2e_metrics_ntg_original.sh {ar} {t_format}'"
    else:
        bashCommand = ''
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully evaluated NTG's text generation!")
        result = True
    else:
        print(f"NTG's text generation evalutation has failed")
    return result

def train_w2b(container, gpu):
    print(f"Training Wiki2Bio in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/wiki2bio/w2b.sh -train {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully trained Wiki2Bio!")
        result = True
    else:
        print(f"Wiki2Bio's training has failed")
    return result

def gen_w2b(container, model, metric, t_format, gpu):
    print(f"Evaluating Wiki2Bio's text generation in {container}...")
    bashCommand = f"docker exec -it {container} bash -c '/root/templates_to_language_evaluation/wiki2bio/w2b.sh -test {model} {metric} {t_format} {gpu}'"
    docker = subprocess.Popen(shlex.split(bashCommand), stdout=sys.stdout, stderr=sys.stderr, encoding='utf-8')
    output, error = docker.communicate()
    returncode = docker.returncode
    result = False
    if returncode == 0:
        print(f"Successfully evaluated Wiki2Bio's text generation!")
        result = True
    else:
        print(f"Wiki2Bio's text generation evalutation has failed")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('-i', '--image', type=str, default='dbsi', help='docker image name')
    parser.add_argument('-c', '--container', type=str, default='dbsc', help='docker container name')
    parser.add_argument('-d', '--directory', type=str, default='./', help='path to project directory')
    
    print("Welcome to Nikos' and Dimitris' awesome DBS project")
    print("Checking if your environment is properly configured...")
    
    args = parser.parse_args()
    
    if not docker_installed():
        print("Install docker and re-run the UI to proceed")
        sys.exit(1)
    
    if not image_exists(args.image):
        result = False
        while True:
            answer = input(f"Build {args.image} docker image? (y/n): ")
            if answer == 'y':
                result = build_image(args.image, args.directory)
                if result:
                    break
                else:
                    sys.exit(1)
            elif answer == 'n':
                print("We can not proceed further without an image")
                sys.exit(1)
            else:
                print("Wrong input")
    
    if not container_exists(args.container):
        result = False
        while True:
            answer = input(f"Create {args.container} container using {args.image} image? (y/n): ")
            if answer == 'y':
                result = create_container(args.container, args.image)
                if result:
                    break
                else:
                    sys.exit(1)
            elif answer == 'n':
                print("We can not proceed further without a container")
                sys.exit(1)
            else:
                print("Wrong input")
                
    if not container_active(args.container):
        result = False
        while True:
            answer = input(f"Activate {args.container} container? (y/n): ")
            if answer == 'y':
                result = activate_container(args.container)
                if result:
                    break
                else:
                    sys.exit(1)
            elif answer == 'n':
                print("We can not proceed further without an active container")
                sys.exit(1)
            else:
                print("Wrong input")
    
    while True:
        result = False
        action = input(
                "What would you like to do?\n" +
                "Press [T]rain to re-train a specific model\n" +
                "Press [G]enerate to generate text outputs using a model\n" +
                "Press [E]valueate to evaluate the outputs of a model\n" +
                "Press [Q]uit to quit\n" +
                "Choice: "
                )
        if action == 'T':
            train = input(
                    "Which model would you like to train?\n" +
                    "Press [T]Gen to train TGen on E2E dataset\n" +
                    "Press [NE] to train NTG on E2E dataset\n" +
                    "Press [NW] to train NTG on WikiBio dataset\n" +
                    "Press [W]iki2Bio to train Wiki2Bio on WikiBio dataset\n" +
                    "Press [B] to return to the previous menu\n" +
                    "Choice: "
                    )
            if train == 'T':
                result = train_tgen(args.container)
            elif train == 'NE':
                dec = ''
                ar = '-nar'
                gpu = ''
                params = input(
                        "Please press [G]PU, [A]utoregressive, [D]ecayed,\n" +
                        "in any order," + 
                        "\n(1)if would like to make use of your " +
                        "GPU (otherwise CPU is used)," +
                        "\n(2)if would like to train the autoregressive " +
                        "variant of the NTG model (otherwise the " +
                        "non-autoregressive variant is used) and" + 
                        "\n(3)if you would like to use the decayed model for " +
                        "template extraction and text generation (otherwise, " +
                        "the non-decayed model is used)\n" +
                        "Choice: "
                        )
                if 'G' in params:
                    gpu = '-cuda'
                if 'A' in params:
                    ar = '-war'
                if 'D' in params:
                    dec = '-decay'
                result = train_ntg(args.container, 'e2e', ar, dec, gpu)
            elif train == 'NW':
                dec = ''
                ar = '-nar'
                gpu = ''
                params = input(
                        "Please press [G]PU, [A]utoregressive, [D]ecayed,\n" +
                        "in any order," + 
                        "\n(1)if would like to make use of your " +
                        "GPU (otherwise CPU is used)," +
                        "\n(2)if would like to train the autoregressive " +
                        "variant of the NTG model (otherwise the " +
                        "non-autoregressive variant is used) and" + 
                        "\n(3)if you would like to use the decayed model for " +
                        "template extraction and text generation (otherwise, " +
                        "the non-decayed model is used)\n" +
                        "Choice: "
                        )
                if 'G' in params:
                    gpu = '-cuda'
                if 'A' in params:
                    ar = '-war'
                if 'D' in params:
                    dec = '-decay'
                result = train_ntg(args.container, 'wb', ar, dec, gpu)
            elif train == 'W':
                gpu = ''
                params = input("Please press [G]PU if would like to make use of your GPU (otherwise CPU is used)\n" +
                               "Choice: "
                               )
                if 'G' in params:
                    gpu = '-cuda'
                result = train_w2b(args.container, gpu)
            elif train != 'B':
                print("Wrong input")
        if action == 'G':
            generate = input(
                    "Which model would you like to generate with?\n" +
                    "Press [T]Gen to generate using TGen on E2E dataset\n" +
                    "Press [NE] to generate using NTG on E2E dataset\n" +
                    "Press [NW] to generate using NTG on WikiBio dataset\n" +
                    "Press [B] to return to the previous menu\n" +
                    "Choice: "
                    )
            if generate == 'T':
                result = gen_tgen(args.container)
            elif generate == 'NE':
                dec = ''
                ar = '-nar'
                gpu = ''
                model = ''
                params = input(
                        "Please press [G]PU, [A]utoregressive, [D]ecayed, [P]retrained\n" +
                        "in any order," + 
                        "\n(1)if would like to make use of your " +
                        "GPU (otherwise CPU is used)," +
                        "\n(2)if would like to train the autoregressive " +
                        "variant of the NTG model (otherwise the " +
                        "non-autoregressive variant is used)," + 
                        "\n(3)if you would like to use the decayed model for " +
                        "text generation (otherwise, the non-decayed model is used) and" +
                        "\n(4)if you would like to use the pre-trained model for " +
                        "text generation (otherwise, the new model is used)\n" +
                        "Choice: "
                        )
                if 'G' in params:
                    gpu = '-cuda'
                if 'A' in params:
                    ar = '-war'
                if 'D' in params:
                    dec = '-decay'
                if 'P' in params:
                    result = gen_ntg_original(args.container, 'e2e', ar, gpu)
                else:
                    result = gen_ntg(args.container, 'e2e', ar, dec, gpu)
            elif generate == 'NW':
                dec = ''
                ar = '-nar'
                gpu = ''
                model = ''
                params = input(
                        "Please press [G]PU, [A]utoregressive, [D]ecayed, [P]retrained\n" +
                        "in any order," + 
                        "\n(1)if would like to make use of your " +
                        "GPU (otherwise CPU is used)," +
                        "\n(2)if would like to train the autoregressive " +
                        "variant of the NTG model (otherwise the " +
                        "non-autoregressive variant is used)," + 
                        "\n(3)if you would like to use the decayed model for " +
                        "text generation (otherwise, the non-decayed model is used) and" +
                        "\n(4)if you would like to use the pre-trained model for " +
                        "text generation (otherwise, the new model is used)\n" +
                        "Choice: "
                        )
                if 'G' in params:
                    gpu = '-cuda'
                if 'A' in params:
                    ar = '-war'
                if 'D' in params:
                    dec = '-decay'
                if 'P' in params:
                    result = gen_ntg_original(args.container, 'wb', ar, gpu)
                else:
                    result = gen_ntg(args.container, 'wb', ar, dec, gpu)
            elif generate != 'B':
                print("Wrong input")
        elif action == 'E':
            evaluate = input(
                    "Which model would you like to evaluate?\n" +
                    "Press [T]Gen to evaluate TGen on E2E dataset\n" +
                    "Press [NE] to evaluate NTG on E2E dataset\n" +
                    "Press [NW] to evaluate NTG on WikiBio dataset (unavailable)\n" +
                    "Press [W] to evaluate Wiki2Bio on WikiBio dataset\n" +
                    "Press [B] to return to the previous menu\n" +
                    "Choice: "
                    )
            if evaluate == 'T':
                t_format = '\'psql\''
                params = input("Please press [T]able " +
                               "if would like to select an alternative " +
                               "table display format (otherwise PSQL is used)\n" +
                               "Choice: "
                               )
                if 'T' in params:
                    formats = input("Please select one of [L]aTeX, [G]itHub, [H]TML, [P]lain\n" +
                                    "Choice: "
                                    )
                    if len(formats) != 1:
                        print("Wrong input")
                        continue
                    elif 'L' in formats:
                        t_format = '\'latex\''
                    elif 'G' in formats:
                        t_format = '\'github\''
                    elif 'H' in formats:
                        t_format = '\'html\''
                    elif 'P' in formats:
                        t_format = '\'plain\''
                result = eval_tgen(args.container, t_format)
            elif evaluate == 'NE':
                dec = ''
                ar = '-nar'
                model = ''
                t_format = '\'psql\''
                params = input(
                        "Please press [A]utoregressive, [D]ecayed, [P]retrained, [T]able\n" +
                        "in any order," + 
                        "\n(1)if would like to evaluate the autoregressive " +
                        "variant of the NTG model (otherwise the " +
                        "non-autoregressive variant is used)," + 
                        "\n(2)if you would like to evaluate the decayed model " +
                        "(otherwise, the non-decayed model is used)," +
                        "\n(3)if you would like to evaluate the pre-trained model " +
                        "(otherwise, the new model is used) and" +
                        "\n(4)if would like to select an alternative " +
                        "table display format (otherwise PSQL is used)\n" +
                        "Choice: "
                        )
                if 'A' in params:
                    ar = '-war'
                if 'D' in params:
                    dec = '-decay'
                if 'T' in params:
                    formats = input("Please select one of [L]aTeX, [G]itHub, [H]TML, [P]lain\n" +
                                    "Choice: "
                                    )
                    if len(formats) != 1:
                        print("Wrong input")
                        continue
                    elif 'L' in formats:
                        t_format = '\'latex\''
                    elif 'G' in formats:
                        t_format = '\'github\''
                    elif 'H' in formats:
                        t_format = '\'html\''
                    elif 'P' in formats:
                        t_format = '\'plain\''
                if 'P' in params:
                    result = eval_ntg_original(args.container, 'e2e', ar, t_format)
                else:
                    result = eval_ntg(args.container, 'e2e', dec, ar, t_format)
            #elif evaluate == 'NW':
                #dec = ''
                #ar = '-nar'
                #model = ''
                #params = input(
                        #"Please press [G]PU, [A]utoregressive, [D]ecayed, [P]retrained\n" +
                        #"in any order," + 
                        #"\n(1)if would like to evaluate the autoregressive " +
                        #"variant of the NTG model (otherwise the " +
                        #"non-autoregressive variant is used)," + 
                        #"\n(2)if you would like to evaluate the decayed model " +
                        #"(otherwise, the non-decayed model is used) and" +
                        #"\n(3)if you would like to evaluate the pre-trained model " +
                        #"(otherwise, the new model is used)\n" +
                        #"Choice: "
                        #)
                #if 'A' in params:
                    #ar = '-war'
                #if 'D' in params:
                    #dec = '-decay'
                #if 'P' in params:
                    #result = eval_ntg_original(args.container, 'wb', ar, t_format)
                #else:
                    #result = eval_ntg(args.container, 'wb', dec, ar, t_format)
            elif evaluate == 'W':
                gpu = ''
                model = 'new'
                metric = '\'BLEU\''
                t_format = '\'psql\''
                params = input("Please press [G]PU, [P]retrained, [R]ouge, [T]able\n" +
                               "in any order," +
                               "\n(1)if would like to make use of " +
                               "your GPU (otherwise CPU is used)," +
                               "\n(2)if would like to evaluate the " +
                               "pre-trained model (otherwise " +
                               "the newly trained model is evaluated)," +
                               "\n(3)if would like to evaluate using " +
                               "ROUGE as a metric (otherwise " +
                               "BLEU is used for evaluation) and" +
                               "\n(4)if would like to select an alternative " +
                               "table display format (otherwise PSQL is used)\n" +
                               "Choice: "
                               )
                if 'G' in params:
                    gpu = '-cuda'
                if 'P' in params:
                    model = 'old'
                if 'R' in params:
                    metric = '\'ROUGE\''
                if 'T' in params:
                    formats = input("Please select one of [L]aTeX, [G]itHub, [H]TML, [P]lain\n" +
                                    "Choice: "
                                    )
                    if len(formats) != 1:
                        print("Wrong input")
                        continue
                    elif 'L' in formats:
                        t_format = '\'latex\''
                    elif 'G' in formats:
                        t_format = '\'github\''
                    elif 'H' in formats:
                        t_format = '\'html\''
                    elif 'P' in formats:
                        t_format = '\'plain\''
                result = gen_w2b(args.container, model, metric, t_format, gpu)
            elif evaluate != 'B':
                print("Wrong input")
        elif action == 'Q':
            break
        else:
            print("Wrong input")
        
    sys.exit(0)
