worker_processes 8 # assuming eight CPU cores

Rainbows! do
  use :FiberSpawn
  worker_connections 100
end

