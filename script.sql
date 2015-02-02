drop sequence channel_seq;
CREATE SEQUENCE channel_seq
    MINVALUE 1
    MAXVALUE 999999999999999999999999999
    START WITH 1
    INCREMENT BY 1;

drop table tchannel cascade constraints;
CREATE TABLE tchannel 
(	id_channel NUMBER, 
	channel NUMBER, 
 CONSTRAINT PK_ID_CHANNEL1 PRIMARY KEY (channel));
 
CREATE OR REPLACE TRIGGER channel_trigger before insert on tchannel
for each row
WHEN (new.id_channel is null) begin
 select channel_seq.nextval into :new.id_channel from dual;
end;

drop sequence box_seq;
CREATE SEQUENCE box_seq
    MINVALUE 1
    MAXVALUE 999999999999999999999999999
    START WITH 1
    INCREMENT BY 1;
	
drop table tbox cascade constraints;
CREATE TABLE tbox 
(	id_box NUMBER, 
	box varchar(300), 
 CONSTRAINT PK_ID_box1 PRIMARY KEY (box));	
 
CREATE OR REPLACE TRIGGER box_trigger before insert on tbox
for each row
WHEN (new.id_box is null) begin
 select box_seq.nextval into :new.id_box from dual;
end;


CREATE VIEW iptv_morning_train AS
select iptv_processed.box_id,
iptv_processed.channel_id,
iptv_processed.content_id,
sum(watch_duration) as watched_duration,
(select total_duration from content_duration where iptv_processed.content_id = content_duration.content_id) as total_duration,
count(content_id) as number_times,
(sum(watch_duration) / (count(content_id)*(select total_duration from content_duration where iptv_processed.content_id = content_duration.content_id))) as percentage_viewed
from iptv_processed
where (iptv_processed.start_hour >=07 and iptv_processed.start_hour < 13) and (iptv_processed.start_day !=27)
group by iptv_processed.box_id, iptv_processed.channel_id, iptv_processed.content_id


create table results_train as
select box_id, channel_id, sum(percentage_viewed) as percentage_viewed from iptv_morning_train
group by box_id, channel_id

insert into tchannel (channel)
select distinct(channel_id) from results_train;

insert into tbox (box)
select distinct(box_id) from results_train;

CREATE VIEW final_results_iptv_train AS
select tbox.id_box, tchannel.id_channel, results_train.percentage_viewed from results_train, tbox, tchannel
where results_train.box_id = tbox.box and results_train.channel_id = tchannel.channel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARA O TESTE

CREATE VIEW iptv_morning_test AS
select iptv_processed.box_id,
iptv_processed.channel_id,
iptv_processed.content_id,
sum(watch_duration) as watched_duration,
(select total_duration from content_duration where iptv_processed.content_id = content_duration.content_id) as total_duration,
count(content_id) as number_times,
(sum(watch_duration) / (count(content_id)*(select total_duration from content_duration where iptv_processed.content_id = content_duration.content_id))) as percentage_viewed
from iptv_processed
where (iptv_processed.start_hour >=07 and iptv_processed.start_hour < 13) and (iptv_processed.start_day =27)
group by iptv_processed.box_id, iptv_processed.channel_id, iptv_processed.content_id

create table results_test as
select box_id, channel_id, sum(percentage_viewed) as percentage_viewed from iptv_morning_test
group by box_id, channel_id

CREATE VIEW final_results_iptv_test AS
select tbox.id_box, tchannel.id_channel, results_test.percentage_viewed from results_train, results_test, tbox, tchannel
where results_train.box_id = results_test.box_id and results_train.channel_id = results_test.channel_id and
results_train.box_id = tbox.box and results_train.channel_id = tchannel.channel



 
