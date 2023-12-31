##############
# Base Image #
##############

FROM ubuntu-base

###############
# Setup Emacs #
###############

RUN \
  sudo cp /etc/apt/sources.list /etc/apt/sources.list~ && \
  sudo sed -Ei "s/^# deb-src/deb-src/" /etc/apt/sources.list && \
  sudo apt update && \
  sudo DEBIAN_FRONTEND=noninteractive apt build-dep -y emacs && \
  sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    libgccjit0 \
    libgccjit-11-dev \
    && \
  sudo rm -rf /var/lib/apt/lists/* && \
  sudo mv /etc/apt/sources.list~ /etc/apt/sources.list && \
  wget https://ftpmirror.gnu.org/emacs/emacs-28.1.tar.xz && \
  tar -xvf emacs-28.1.tar.xz && \
  cd emacs-28.1 && \
  ./autogen.sh && \
  ./configure --with-native-compilation && \
  make -j$(proc) && \
  sudo make install && \
  cd ${HOME} && \
  rm emacs-28.1.tar.xz && \
  rm -rf emacs-28.1

################################
# Setup Doom Emacs Environment #
################################

RUN \
  sudo apt update && \
  sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    fd-find \
    fonts-firacode \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    ripgrep \
    unzip \
    && \
  sudo rm -rf /var/lib/apt/lists/*

RUN \
  wget --output-document Fira_Sans.zip https://fonts.google.com/download?family=Fira%20Sans && \
  unzip Fira_Sans.zip -d Fira_Sans && \
  mkdir -p .fonts && \
  cp Fira_Sans/*.ttf .fonts/ && \
  rm Fira_Sans.zip && \
  rm -rf Fira_Sans && \
  fc-cache -f -v

RUN \
  git clone https://github.com/domtronn/all-the-icons.el.git && \
  cp all-the-icons.el/fonts/*.ttf .fonts/ && \
  rm -rf all-the-icons.el && \
  fc-cache -f -v

RUN \
  printf "\n%s\n" "export NO_AT_BRIDGE=1" >> ${HOME}/.bashrc && \
  printf "\n%s\n" 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ${HOME}/.bashrc

###########
# Startup #
###########

CMD ["/bin/bash"]
