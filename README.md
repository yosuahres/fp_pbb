# Final Project Mobile Programming C | MoTix Kelompok 10

| Name           | NRP        | Class     |
| ---            | ---        | ----------|
| Yosua Hares | 5025221270 | Pemrograman Perangkat Bergerak (C) |
| Ahmad Fadhilah Mappisara | 5025221195 | Pemrograman Perangkat Bergerak (C) |
| Muhammad Alfan Mahdi | 5025221275 | Pemrograman Perangkat Bergerak (C) |

# Description App
Aplikasi mobile untuk pembelian tiket film. Pengguna dapat menjelajahi detail film lengkap dengan sinopsis hingga jadwal. Fitur beli tiket memudahkan pemesanan kursi. Terdapat juga review pengguna serta watchlist untuk menyimpan film favorit dan mengatur rencana menonton.

# API
- The Movie Database: https://api.themoviedb.org/3

# Use Case Diagram
![Uce Case Diagram](images/use_case_diagram.png)

# Activity Diagram
![Activity Diagram](images/activity_diagram.jpg)

# Arsitektur Sistem
![Arsitektur Sistem](images/system_architecture.jpg)

# Fitur dan PIC
| Fitur                | PIC    |
| ---                  | ---    |
| Register             | Hares  |
| Login                | Hares  |
| Home Page            | Fadhil |
| Movie Details        | Alfan  |
| CRUD Beli Tiket      | Hares  |
| CRUD Review Movie    | Fadhil |
| CRUD Watchlist Movie | Alfan  |

# Register (Hares)
Fitur register memungkinkan pengguna baru untuk membuat akun dengan memasukkan nama, email, dan password. Setelah berhasil, pengguna akan diarahkan ke halaman login.
![Register Page](images/register_page.png)

# Login (Hares)
Fitur login memungkinkan pengguna untuk masuk ke akun mereka dengan memasukkan email dan password. Setelah berhasil, pengguna akan diarahkan ke halaman utama aplikasi.
![Login Page](images/login_page.png)

# Home Page (Fadhil)
Fitur home page menampilkan daftar film terbaru dengan poster, judul, dan rating. Pengguna dapat memilih film untuk melihat detail lebih lanjut.
![Home Page 1](images/home_page_1.png)
![Home Page 2](images/home_page_2.png)
![Popular Movies Page](images/popular_movies_page.png)

# Movie Details (Alfan)
Fitur movie details menampilkan informasi lengkap tentang film, termasuk sinopsis, jadwal tayang, dan rating. Pengguna dapat melihat review dari pengguna lain dan menambahkan film ke watchlist.
![Movie Details Page 1](images/movie_details_page_1.png)
![Movie Details Page 2](images/movie_details_page_2.png)

# CRUD Beli Tiket (Hares)
Fitur beli tiket memungkinkan pengguna untuk memilih film, jadwal, dan kursi. Setelah memilih, pengguna dapat melakukan pembayaran dan mendapatkan tiket digital.
![Buy Ticket Page 1](images/buy_ticket_page_1.png)
![Buy Ticket Page 2](images/buy_ticket_page_2.png)

# CRUD Review Movie (Fadhil)
Fitur review movie memungkinkan pengguna untuk menulis, mengedit, dan menghapus review tentang film yang telah ditonton. Review dapat membantu pengguna lain dalam memilih film.
![Review Movie Page 1](images/reviews_page_1.png)
![Review Movie Page 2](images/reviews_page_2.png)

# CRUD Watchlist Movie (Alfan)
Fitur watchlist movie memungkinkan pengguna untuk menambahkan film ke daftar tonton mereka. Pengguna dapat mengelola daftar ini dengan menambahkan atau menghapus film sesuai keinginan.
![Watchlist Page](images/watchlist_movies_page.png)