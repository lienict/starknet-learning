- create project : scarb new
-  build: scarb build
- run: scarb cairo-run
//
https://starknet-by-example.voyager.online/getting-started/basics/variables.html
# Biến trong starknet cairo contract
- local: định nghĩa bên trong function và không được lưu trong blockchain (lưu trong memory, k lưu ở blockchain)
- storage: Định nghĩa bên trong Storage( key-value), chỉ access trong contract (persistent data được lưu trên blockchain)
- global: cung cấp các thông tin ở blockchain (global) truy cập everywhere

# Visibility and Mutability
-  #[abi(embed_v0)] : is only call external
# Error
- Có 2 loại để handle là assert và panic
- assert: để sử dụng để validate input
- panic: sử dụng để check lỗi nội bộ