<?xml version="1.0" encoding="UTF-8"?>
<tileset name="dungeon_room_behaviors" tilewidth="16" tileheight="16" tilecount="1000" columns="40">
 <image source="dungeon_room_behaviors.png" width="640" height="400"/>
 <tile id="0">
  <properties>
   <property name="name" value="start"/>
  </properties>
 </tile>
 <tile id="1">
  <properties>
   <property name="name" value="end"/>
  </properties>
 </tile>
 <tile id="2">
  <properties>
   <property name="clickable" value="false"/>
   <property name="name" value="unexplored"/>
  </properties>
 </tile>
 <tile id="3">
  <properties>
   <property name="clickable" value="true"/>
   <property name="name" value="explored"/>
  </properties>
 </tile>
 <tile id="4">
  <properties>
   <property name="clickable" value="true"/>
   <property name="name" value="explorable"/>
  </properties>
 </tile>
</tileset>
