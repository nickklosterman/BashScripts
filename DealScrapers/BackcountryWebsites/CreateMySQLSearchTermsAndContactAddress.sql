create table SearchTermsAndContactAddress ( prim_key INT NOT NULL Auto_increment Primary key, searchterms varchar(64), contactaddress varchar(64), ImageAttachment tinyint(1) );

create table SearchTermsAndContactAddress2 ( prim_key INT NOT NULL Auto_increment Primary key, searchterms varchar(64), contactaddress varchar(64), ImageAttachment tinyint(1) );

create table SearchTermsAndContactAddress2 ( prim_key INT NOT NULL Auto_increment Primary key, searchterms varchar(64), contactaddress varchar(64), ImageAttachment tinyint(1) ) TYPE=MyISAM AUTO_INCREMENT=7;

INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist1", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist12", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist123", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist1234", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist12345", "bob@joe.com" , 0 );
INSERT INTO SearchTermsAndContactAddress2 (searchterms, contactaddress, ImageAttachment) VALUES ( "hist123456", "bob@joe.com" , 0 );


------------------

CREATE TABLE `test_mysql2` (`id` int(4) NOT NULL auto_increment,`name` varchar(65) NOT NULL default '',`lastname` varchar(65) NOT NULL default '',`email` varchar(65) NOT NULL default '',PRIMARY KEY (`id`) );

CREATE TABLE `test_mysql` (`id` int(4) NOT NULL auto_increment,`name` varchar(65) NOT NULL default '',`lastname` varchar(65) NOT NULL default '',`email` varchar(65) NOT NULL default '',PRIMARY KEY (`id`) ) TYPE=MyISAM AUTO_INCREMENT=7


INSERT INTO `test_mysql` VALUES (1, 'Billly', 'Blueton', 'bb5@phpeasystep.com');
INSERT INTO `test_mysql` VALUES (2, 'Jame', 'Campbell', 'jame@somewhere.com');
INSERT INTO `test_mysql` VALUES (3, 'Mark', 'Jackson', 'mark@phpeasystep.com');
INSERT INTO `test_mysql` VALUES (4, 'Linda', 'Travor', 'lin65@phpeasystep.com');
INSERT INTO `test_mysql` VALUES (5, 'Joey', 'Ford', 'fordloi@somewhere.com');
INSERT INTO `test_mysql` VALUES (6, 'Sidney', 'Gibson', 'gibson@phpeasystep.com');

INSERT INTO `test_mysql2` VALUES (1, 'Billly', 'Blueton', 'bb5@phpeasystep.com');
INSERT INTO `test_mysql2` VALUES (2, 'Jame', 'Campbell', 'jame@somewhere.com');
INSERT INTO `test_mysql2` VALUES (3, 'Mark', 'Jackson', 'mark@phpeasystep.com');
INSERT INTO `test_mysql2` VALUES (4, 'Linda', 'Travor', 'lin65@phpeasystep.com');
INSERT INTO `test_mysql2` VALUES (5, 'Joey', 'Ford', 'fordloi@somewhere.com');
INSERT INTO `test_mysql2` VALUES (6, 'Sidney', 'Gibson', 'gibson@phpeasystep.com');;


--IT WORKS WO BEING MYISAM 

CREATE TABLE `fuckme` (`id` int(4) NOT NULL auto_increment,`name` varchar(65) NOT NULL default '',`lastname` varchar(65) NOT NULL default '',`email` varchar(65) NOT NULL default '',PRIMARY KEY (`id`) );

INSERT INTO `fuckme` VALUES (1, 'Billly', 'Blueton', 'bb5@phpeasystep.com');
INSERT INTO `fuckme` VALUES (2, 'Jame', 'Campbell', 'jame@somewhere.com');
INSERT INTO `fuckme` VALUES (3, 'Mark', 'Jackson', 'mark@phpeasystep.com');
INSERT INTO `fuckme` VALUES (4, 'Linda', 'Travor', 'lin65@phpeasystep.com');
INSERT INTO `fuckme` VALUES (5, 'Joey', 'Ford', 'fordloi@somewhere.com');
INSERT INTO `fuckme` VALUES (6, 'Sidney', 'Gibson', 'gibson@phpeasystep.com');;

--this worked as well ^^^^^

CREATE TABLE `fuckme2` (`pid` int(4) NOT NULL auto_increment,`name` varchar(65) NOT NULL default '',`lastname` varchar(65) NOT NULL default '',`email` varchar (65) NOT NULL default '',PRIMARY KEY (`pid`) );

INSERT INTO `fuckme2` VALUES (1, 'Billly', 'Blueton', 'bb5@phpeasystep.com');
INSERT INTO `fuckme2` VALUES (2, 'Jame', 'Campbell', 'jame@somewhere.com');
INSERT INTO `fuckme2` VALUES (3, 'Mark', 'Jackson', 'mark@phpeasystep.com');
INSERT INTO `fuckme2` VALUES (4, 'Linda', 'Travor', 'lin65@phpeasystep.com');
INSERT INTO `fuckme2` VALUES (5, 'Joey', 'Ford', 'fordloi@somewhere.com');
INSERT INTO `fuckme2` VALUES (6, 'Sidney', 'Gibson', 'gibson@phpeasystep.com');

