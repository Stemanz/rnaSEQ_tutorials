sudo apt remove --purge r-base r-base-core r-recommended
sudo rm -rf /usr/local/lib/R
sudo rm -rf ~/R
sudo apt autoremove

sudo apt update
sudo apt install -y software-properties-common dirmngr gnupg curl ca-certificates

sudo apt install -y \
  build-essential \
  gfortran \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libblas-dev \
  liblapack-dev \
  libhdf5-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev

curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
| sudo gpg --dearmor -o /usr/share/keyrings/cran.gpg

echo "deb [signed-by=/usr/share/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
| sudo tee /etc/apt/sources.list.d/cran.list

sudo apt update

sudo apt install -y r-base r-base-dev

R --version

echo "Should be R version 4.4.x 2024-xx-xx, if not something went wrong"
