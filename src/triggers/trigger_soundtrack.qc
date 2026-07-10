// trigger_soundtrack.qc
// Muda a musica quando o jogador entra no trigger
//
// Uso no mapa:
//   - Crie uma entidade trigger_soundtrack
//   - Defina o campo "sounds" com o numero da track desejada (ex: 2)
//   - O brush vira o gatilho, basta o jogador entrar nele
//
// Musicas ficam em id1/music/trackXX.ogg ou trackXX.mp3

void(float newtrack) changemusic = {
	*world_sounds = newtrack;  //changing the field via a pointer
	//world.sounds has now been changed via our pointer, newly connecting players
	// (like those connecting after the game is loaded) will get sent the new cd track's number.

	//let everyone currently on the server know.
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, newtrack);  //initial track
	WriteByte(MSG_ALL, newtrack);  //looped track... should generally be set the same as the initial track as most engines ignore it entirely so it might as well be sane for those that care.
};

void() music_touch =
{
	if (self.estate != STATE_ACTIVE)
		return;

	if (other.classname != "player")
		return;

	self.touch = SUB_Null;

	changemusic(self.sounds);
};

void() music_use = {
	if (self.estate != STATE_ACTIVE)
		return;

	changemusic(self.sounds);
}

void() trigger_soundtrack =
{
	InitTrigger();
	self.touch = music_touch;
	self.use = music_use;

	SUB_CheckWaiting();
};

void() target_soundtrack =
{

	self.use = music_use;
};
