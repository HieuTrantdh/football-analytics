/* Sau khi convert scripts sẽ làm mất PK của các bảng, đây là phần thêm */

ALTER TABLE player ADD PRIMARY KEY (id);
ALTER TABLE team ADD PRIMARY KEY (id);
ALTER TABLE country ADD PRIMARY KEY (id);
ALTER TABLE league ADD PRIMARY KEY (id);
ALTER TABLE playerstats ADD PRIMARY KEY (id);
ALTER TABLE team_attributes ADD PRIMARY KEY (id);
ALTER TABLE `match` ADD PRIMARY KEY (id);
