% Knowledge base: components

% CPUs - cpu(Name, Brand, Socket, Price, Cores, Threads, Tier, Score)
cpu('Intel Core i3-12100F', intel, lga1700, 110, 4, 8, budget, 75).
cpu('Intel Core i5-12400F', intel, lga1700, 160, 6, 12, budget, 85).
cpu('Intel Core i5-13400F', intel, lga1700, 200, 10, 16, mid_range, 88).
cpu('Intel Core i5-14600K', intel, lga1700, 320, 14, 20, mid_range, 90).
cpu('Intel Core i7-13700K', intel, lga1700, 400, 16, 24, high_end, 92).
cpu('Intel Core i7-14700K', intel, lga1700, 420, 20, 28, high_end, 94).
cpu('Intel Core i9-13900K', intel, lga1700, 580, 24, 32, enthusiast, 96).
cpu('Intel Core i9-14900K', intel, lga1700, 600, 24, 32, enthusiast, 98).
cpu('AMD Ryzen 5 5600', amd, am4, 130, 6, 12, budget, 80).
cpu('AMD Ryzen 7 5700X', amd, am4, 180, 8, 16, budget, 84).
cpu('AMD Ryzen 5 7600', amd, am5, 220, 6, 12, mid_range, 87).
cpu('AMD Ryzen 7 7700X', amd, am5, 300, 8, 16, mid_range, 89).
cpu('AMD Ryzen 7 7800X3D', amd, am5, 450, 8, 16, high_end, 95).
cpu('AMD Ryzen 9 7900X', amd, am5, 500, 12, 24, high_end, 93).
cpu('AMD Ryzen 9 7950X', amd, am5, 700, 16, 32, enthusiast, 97).
cpu('AMD Ryzen 9 7950X3D', amd, am5, 750, 16, 32, enthusiast, 99).

% Motherboards - motherboard(Name, Socket, Chipset, Price, Tier, RamType, Score)
motherboard('ASRock B660M-HDV', lga1700, b660, 90, budget, ddr4, 70).
motherboard('Gigabyte B760M DS3H', lga1700, b760, 120, budget, ddr4, 75).
motherboard('MSI MAG B760 Tomahawk', lga1700, b760, 180, mid_range, ddr5, 85).
motherboard('ASUS TUF Gaming Z690', lga1700, z690, 250, mid_range, ddr5, 88).
motherboard('ASUS ROG Strix Z790-E', lga1700, z790, 380, high_end, ddr5, 93).
motherboard('MSI MEG Z790 ACE', lga1700, z790, 500, enthusiast, ddr5, 96).
motherboard('Gigabyte B550M DS3H', am4, b550, 90, budget, ddr4, 72).
motherboard('MSI B550 Tomahawk', am4, b550, 150, mid_range, ddr4, 82).
motherboard('ASUS ROG Strix B550-F', am4, b550, 180, mid_range, ddr4, 85).
motherboard('MSI MAG B650 Tomahawk', am5, b650, 200, mid_range, ddr5, 86).
motherboard('ASUS TUF Gaming X670E', am5, x670e, 350, high_end, ddr5, 92).
motherboard('ASUS ROG Strix X670E-E', am5, x670e, 450, high_end, ddr5, 94).
motherboard('MSI MEG X670E ACE', am5, x670e, 600, enthusiast, ddr5, 97).

% RAM - ram(Name, Capacity, Type, Speed, Price, Tier, Score, HasRGB)
ram('Corsair Vengeance 8GB DDR4-3200', 8, ddr4, 3200, 25, budget, 70, no).
ram('Corsair Vengeance 16GB DDR4-3200', 16, ddr4, 3200, 45, budget, 78, no).
ram('Kingston Fury 16GB DDR4-3600', 16, ddr4, 3600, 55, budget, 80, yes).
ram('G.Skill Ripjaws 32GB DDR4-3600', 32, ddr4, 3600, 80, mid_range, 85, no).
ram('Corsair Vengeance 16GB DDR5-5600', 16, ddr5, 5600, 70, mid_range, 83, yes).
ram('Corsair Vengeance 32GB DDR5-5600', 32, ddr5, 5600, 130, mid_range, 88, yes).
ram('G.Skill Trident Z5 32GB DDR5-6000', 32, ddr5, 6000, 160, high_end, 92, yes).
ram('G.Skill Trident Z5 64GB DDR5-6000', 64, ddr5, 6000, 280, high_end, 94, yes).
ram('Corsair Dominator 64GB DDR5-6400', 64, ddr5, 6400, 350, enthusiast, 97, yes).

% GPUs - gpu(Name, Brand, Price, Tier, TDP, Score)
gpu('NVIDIA GTX 1660 Super', nvidia, 230, budget, 125, 72).
gpu('AMD RX 6600', amd, 250, budget, 132, 75).
gpu('NVIDIA RTX 3060', nvidia, 300, budget, 170, 78).
gpu('AMD RX 6700 XT', amd, 350, mid_range, 230, 84).
gpu('NVIDIA RTX 4060 Ti', nvidia, 450, mid_range, 160, 85).
gpu('NVIDIA RTX 4070', nvidia, 550, mid_range, 200, 88).
gpu('AMD RX 7800 XT', amd, 500, high_end, 263, 91).
gpu('NVIDIA RTX 4070 Ti', nvidia, 800, high_end, 285, 93).
gpu('NVIDIA RTX 4080', nvidia, 1100, high_end, 320, 95).
gpu('AMD RX 7900 XTX', amd, 1000, high_end, 355, 94).
gpu('NVIDIA RTX 4090', nvidia, 1600, enthusiast, 450, 99).

% Storage - storage(Name, Type, Capacity, Price, Tier, Score)
storage('WD Blue 500GB NVMe', nvme, 500, 50, budget, 70).
storage('Kingston NV2 1TB NVMe', nvme, 1000, 65, budget, 75).
storage('WD Black SN770 1TB NVMe', nvme, 1000, 75, budget, 78).
storage('Samsung 980 1TB NVMe', nvme, 1000, 80, mid_range, 82).
storage('Samsung 980 Pro 1TB NVMe', nvme, 1000, 120, mid_range, 88).
storage('Samsung 990 Pro 2TB NVMe', nvme, 2000, 180, high_end, 93).
storage('WD Black SN850X 2TB NVMe', nvme, 2000, 200, high_end, 92).
storage('Samsung 990 Pro 4TB NVMe', nvme, 4000, 400, enthusiast, 96).

% PSUs - psu(Name, Wattage, Efficiency, Price, Tier, Score)
psu('EVGA 600 BR', 600, bronze, 50, budget, 70).
psu('Corsair CX650M', 650, bronze, 70, budget, 75).
psu('Corsair RM750e', 750, gold, 100, mid_range, 85).
psu('EVGA SuperNOVA 850 GT', 850, gold, 130, mid_range, 87).
psu('Seasonic Focus GX-850', 850, gold, 140, high_end, 90).
psu('Corsair RM1000e', 1000, gold, 180, high_end, 92).
psu('Corsair HX1000', 1000, platinum, 200, enthusiast, 95).
psu('Seasonic Prime TX-1300', 1300, titanium, 350, enthusiast, 98).

% Cases - case(Name, FormFactor, Price, Tier, Score, HasRGB, AIOSupport)
case('Cooler Master Q300L', micro_atx, 45, budget, 68, no, no).
case('Deepcool MATREXX 40', micro_atx, 60, budget, 72, yes, no).
case('Corsair 4000D', atx, 75, budget, 78, no, yes).
case('NZXT H510', atx, 80, mid_range, 82, yes, yes).
case('Fractal Design Meshify 2', atx, 130, high_end, 90, no, yes).
case('Corsair 5000D Airflow', atx, 140, high_end, 92, yes, yes).
case('Lian Li O11 Dynamic', atx, 150, enthusiast, 95, yes, yes).
