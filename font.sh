# 1. Unzip the file
unzip FiraCode.zip -d FiraCodeFont

# 2. Create the local font directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# 3. Move the .ttf (or .otf) files to the fonts folder
cp FiraCodeFont/*.ttf ~/.local/share/fonts/

# 4. Update the system font cache
fc-cache -f -v