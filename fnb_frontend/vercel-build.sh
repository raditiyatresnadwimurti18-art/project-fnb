#!/bin/bash
echo "Men-download Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

echo "Menjalankan Flutter Build Web..."
./flutter/bin/flutter build web --release

echo "Build Selesai!"
