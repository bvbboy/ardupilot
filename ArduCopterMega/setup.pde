// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-

// Functions called from the setup menu
static int8_t	setup_radio				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_motors			(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_accel				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_factory			(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_erase				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_flightmodes		(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_pid				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_frame				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_current			(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_sonar				(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_compass			(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_mag_offset		(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_declination		(uint8_t argc, const Menu::arg *argv);
static int8_t	setup_show				(uint8_t argc, const Menu::arg *argv);

// Command/function table for the setup menu
const struct Menu::command setup_menu_commands[] PROGMEM = {
	// command			function called
	// =======        	===============
	{"erase", 			setup_erase},
	{"reset", 			setup_factory},
	{"pid",				setup_pid},
	{"radio",			setup_radio},
	{"motors",			setup_motors},
	{"level",			setup_accel},
	{"modes",			setup_flightmodes},
	{"frame",			setup_frame},
	{"current",			setup_current},
	{"sonar",			setup_sonar},
	{"compass",			setup_compass},
	{"mag_offset",		setup_mag_offset},
	{"declination",		setup_declination},
	{"show",			setup_show},
	{"ap_show",			AP_Var_menu_show}
};

// Create the setup menu object.
MENU(setup_menu, "setup", setup_menu_commands);

// Called from the top-level menu to run the setup menu.
int8_t
setup_mode(uint8_t argc, const Menu::arg *argv)
{
	// Give the user some guidance
	Serial.printf_P(PSTR("Setup Mode\n"
						 "\n"
						 "IMPORTANT: if you have not previously set this system up, use the\n"
						 "'reset' command to initialize the EEPROM to sensible default values\n"
						 "and then the 'radio' command to configure for your radio.\n"
						 "\n"));

	// Run the setup menu.  When the menu exits, we will return to the main menu.
	setup_menu.run();
}

// Print the current configuration.
// Called by the setup menu 'show' command.
static int8_t
setup_show(uint8_t argc, const Menu::arg *argv)
{
	uint8_t		i;
	// clear the area
	print_blanks(8);

	report_radio();
	report_frame();
	report_current();
	report_sonar();
	report_gains();
	report_xtrack();
	report_throttle();
	report_flight_modes();
	report_imu();
	report_compass();
	return(0);
}

// Initialise the EEPROM to 'factory' settings (mostly defined in APM_Config.h or via defaults).
// Called by the setup menu 'factoryreset' command.
static int8_t
setup_factory(uint8_t argc, const Menu::arg *argv)
{

	uint8_t		i;
	int			c;

	Serial.printf_P(PSTR("\nType 'Y' and hit Enter to perform factory reset, any other key to abort:\n"));

	do {
		c = Serial.read();
	} while (-1 == c);

	if (('y' != c) && ('Y' != c))
		return(-1);
	AP_Var::erase_all();
	Serial.printf_P(PSTR("\nFACTORY RESET complete - please reset APM to continue"));
	for (;;) {
	}

	// note, cannot actually return here
	return(0);

	//zero_eeprom();
	//default_gains();


	// setup default values
	/*
	default_waypoint_info();
	default_nav();
	default_alt_hold();
	default_frame();
	default_flight_modes();
	default_throttle();
	default_logs();
	default_current();
	print_done();
	*/
	// finish
	// ------
	//return(0);
}

// Perform radio setup.
// Called by the setup menu 'radio' command.
static int8_t
setup_radio(uint8_t argc, const Menu::arg *argv)
{
	Serial.println("\n\nRadio Setup:");
	uint8_t i;

	for(i = 0; i < 100;i++){
		delay(20);
		read_radio();
	}

	if(g.rc_1.radio_in < 500){
		while(1){
			Serial.printf_P(PSTR("\nNo radio; Check connectors."));
			delay(1000);
			// stop here
		}
	}

	g.rc_1.radio_min = g.rc_1.radio_in;
	g.rc_2.radio_min = g.rc_2.radio_in;
	g.rc_3.radio_min = g.rc_3.radio_in;
	g.rc_4.radio_min = g.rc_4.radio_in;
	g.rc_5.radio_min = g.rc_5.radio_in;
	g.rc_6.radio_min = g.rc_6.radio_in;
	g.rc_7.radio_min = g.rc_7.radio_in;
	g.rc_8.radio_min = g.rc_8.radio_in;

	g.rc_1.radio_max = g.rc_1.radio_in;
	g.rc_2.radio_max = g.rc_2.radio_in;
	g.rc_3.radio_max = g.rc_3.radio_in;
	g.rc_4.radio_max = g.rc_4.radio_in;
	g.rc_5.radio_max = g.rc_5.radio_in;
	g.rc_6.radio_max = g.rc_6.radio_in;
	g.rc_7.radio_max = g.rc_7.radio_in;
	g.rc_8.radio_max = g.rc_8.radio_in;

	g.rc_1.radio_trim = g.rc_1.radio_in;
	g.rc_2.radio_trim = g.rc_2.radio_in;
	g.rc_4.radio_trim = g.rc_4.radio_in;
	// 3 is not trimed
	g.rc_5.radio_trim = 1500;
	g.rc_6.radio_trim = 1500;
	g.rc_7.radio_trim = 1500;
	g.rc_8.radio_trim = 1500;


	Serial.printf_P(PSTR("\nMove all controls to each extreme. Hit Enter to save: "));
	while(1){

		delay(20);
		// Filters radio input - adjust filters in the radio.pde file
		// ----------------------------------------------------------
		read_radio();

		g.rc_1.update_min_max();
		g.rc_2.update_min_max();
		g.rc_3.update_min_max();
		g.rc_4.update_min_max();
		g.rc_5.update_min_max();
		g.rc_6.update_min_max();
		g.rc_7.update_min_max();
		g.rc_8.update_min_max();

		if(Serial.available() > 0){
			//g.rc_3.radio_max += 250;
			Serial.flush();

			save_EEPROM_radio();
			//delay(100);
			// double checking
			//read_EEPROM_radio();
			//print_radio_values();
			print_done();
			break;
		}
	}
	report_radio();
	return(0);
}

static int8_t
setup_motors(uint8_t argc, const Menu::arg *argv)
{
	report_frame();

	init_rc_in();

	// read the radio to set trims
	// ---------------------------
	trim_radio();

	print_hit_enter();
	delay(1000);


	int out_min = g.rc_3.radio_min + 70;



	while(1){
		delay(20);
		read_radio();
		motor_out[CH_1]	= g.rc_3.radio_min;
		motor_out[CH_2]	= g.rc_3.radio_min;
		motor_out[CH_3]	= g.rc_3.radio_min;
		motor_out[CH_4] = g.rc_3.radio_min;



		if(g.frame_type == PLUS_FRAME){
			if(g.rc_1.control_in > 0){
				motor_out[CH_1] 	= out_min;
				Serial.println("0");

			}else if(g.rc_1.control_in < 0){
				motor_out[CH_2]		= out_min;
				Serial.println("1");
			}

			if(g.rc_2.control_in > 0){
				motor_out[CH_4] 	= out_min;
				Serial.println("3");

			}else if(g.rc_2.control_in < 0){
				motor_out[CH_3]	= out_min;
				Serial.println("2");
			}

		}else if(g.frame_type == X_FRAME){

			// lower right
			if((g.rc_1.control_in > 0) 		&& (g.rc_2.control_in > 0)){
				motor_out[CH_4] 	= out_min;
				Serial.println("3");
			// lower left
			}else if((g.rc_1.control_in < 0) 	&& (g.rc_2.control_in > 0)){
				motor_out[CH_2]		= out_min;
				Serial.println("1");

			// upper left
			}else if((g.rc_1.control_in < 0) 	&& (g.rc_2.control_in < 0)){
				motor_out[CH_3]	= out_min;
				Serial.println("2");

			// upper right
			}else if((g.rc_1.control_in > 0) 	&& (g.rc_2.control_in < 0)){
				motor_out[CH_1]	= out_min;
				Serial.println("0");
			}

		}else if(g.frame_type == TRI_FRAME){

			if(g.rc_1.control_in > 0){
				motor_out[CH_1] 	= out_min;

			}else if(g.rc_1.control_in < 0){
				motor_out[CH_2]		= out_min;
			}

			if(g.rc_2.control_in > 0){
				motor_out[CH_4] 	= out_min;
			}

			if(g.rc_4.control_in > 0){
				g.rc_4.servo_out	= 2000;

			}else if(g.rc_4.control_in < 0){
				g.rc_4.servo_out	= -2000;
			}

			g.rc_4.calc_pwm();
			motor_out[CH_3] 	= g.rc_4.radio_out;
		}

		if(g.rc_3.control_in > 0){
			APM_RC.OutputCh(CH_1, g.rc_3.radio_in);
			APM_RC.OutputCh(CH_2, g.rc_3.radio_in);
			APM_RC.OutputCh(CH_3, g.rc_3.radio_in);
			if(g.frame_type != TRI_FRAME)
				APM_RC.OutputCh(CH_4, g.rc_3.radio_in);
		}else{
			APM_RC.OutputCh(CH_1, motor_out[CH_1]);
			APM_RC.OutputCh(CH_2, motor_out[CH_2]);
			APM_RC.OutputCh(CH_3, motor_out[CH_3]);
			APM_RC.OutputCh(CH_4, motor_out[CH_4]);
		}

		if(Serial.available() > 0){
			return (0);
		}
	}
}

static int8_t
setup_accel(uint8_t argc, const Menu::arg *argv)
{
	Serial.printf_P(PSTR("\nHold ArduCopter completely still and level.\n"));

	imu.init_accel();
	print_accel_offsets();

	report_imu();
	return(0);
}

static int8_t
setup_pid(uint8_t argc, const Menu::arg *argv)
{
	if (!strcmp_P(argv[1].str, PSTR("default"))) {
		default_gains();

	}else if (!strcmp_P(argv[1].str, PSTR("s_kp"))) {
		g.pid_stabilize_roll.kP(argv[2].f);
		g.pid_stabilize_pitch.kP(argv[2].f);
		save_EEPROM_PID();

	}else if (!strcmp_P(argv[1].str, PSTR("s_kd"))) {
		g.stabilize_dampener = argv[2].f;
		save_EEPROM_PID();

	}else if (!strcmp_P(argv[1].str, PSTR("y_kp"))) {
		g.pid_yaw.kP(argv[2].f);
		save_EEPROM_PID();

	}else if (!strcmp_P(argv[1].str, PSTR("s_kd"))) {
		g.pid_yaw.kD(argv[2].f);
		save_EEPROM_PID();

	}else if (!strcmp_P(argv[1].str, PSTR("t_kp"))) {
		g.pid_baro_throttle.kP(argv[2].f);
		save_EEPROM_PID();

	}else if (!strcmp_P(argv[1].str, PSTR("t_kd"))) {
		g.pid_baro_throttle.kD(argv[2].f);
		save_EEPROM_PID();
	}else{
		default_gains();
	}


	report_gains();
}

static int8_t
setup_flightmodes(uint8_t argc, const Menu::arg *argv)
{
	byte switchPosition, oldSwitchPosition, mode;

	Serial.printf_P(PSTR("\nMove RC toggle switch to each position to edit, move aileron stick to select modes."));
	print_hit_enter();
	trim_radio();

	while(1){
		delay(20);
		read_radio();
		switchPosition = readSwitch();


		// look for control switch change
		if (oldSwitchPosition != switchPosition){

			mode = g.flight_modes[switchPosition];
			mode = constrain(mode, 0, NUM_MODES-1);

			// update the user
			print_switch(switchPosition, mode);

			// Remember switch position
			oldSwitchPosition = switchPosition;
		}

		// look for stick input
		if (radio_input_switch() == true){
			mode++;
			if(mode >= NUM_MODES)
				mode = 0;

			// save new mode
			g.flight_modes[switchPosition] = mode;

			// print new mode
			print_switch(switchPosition, mode);
		}

		// escape hatch
		if(Serial.available() > 0){
			save_EEPROM_flight_modes();
			print_done();
			report_flight_modes();
			return (0);
		}
	}
}

static int8_t
setup_declination(uint8_t argc, const Menu::arg *argv)
{
	compass.set_declination(radians(argv[1].f));
	report_compass();
}

static int8_t
setup_erase(uint8_t argc, const Menu::arg *argv)
{
	zero_eeprom();
	return 0;
}

static int8_t
setup_compass(uint8_t argc, const Menu::arg *argv)
{
	if (!strcmp_P(argv[1].str, PSTR("on"))) {
		g.compass_enabled = true;
		init_compass();

	} else if (!strcmp_P(argv[1].str, PSTR("off"))) {
		g.compass_enabled = false;

	} else {
		Serial.printf_P(PSTR("\nOptions:[on,off]\n"));
		report_compass();
		return 0;
	}

	save_EEPROM_mag();
	report_compass();
	return 0;
}

static int8_t
setup_frame(uint8_t argc, const Menu::arg *argv)
{
	if (!strcmp_P(argv[1].str, PSTR("+"))) {
		g.frame_type = PLUS_FRAME;

	} else if (!strcmp_P(argv[1].str, PSTR("x"))) {
		g.frame_type = X_FRAME;

	} else if (!strcmp_P(argv[1].str, PSTR("tri"))) {
		g.frame_type = TRI_FRAME;

	} else if (!strcmp_P(argv[1].str, PSTR("hexa"))) {
		g.frame_type = HEXA_FRAME;

	} else {
		Serial.printf_P(PSTR("\nOptions:[+, x, tri, hexa]\n"));
		report_frame();
		return 0;
	}

	save_EEPROM_frame();
	report_frame();
	return 0;
}

static int8_t
setup_current(uint8_t argc, const Menu::arg *argv)
{
	if (!strcmp_P(argv[1].str, PSTR("on"))) {
		g.current_enabled.set(true);
		save_EEPROM_mag();

	} else if (!strcmp_P(argv[1].str, PSTR("off"))) {
		g.current_enabled.set(false);
		save_EEPROM_mag();

	} else if(argv[1].i > 10){
		g.milliamp_hours = argv[1].i;

	} else {
		Serial.printf_P(PSTR("\nOptions:[on, off, mAh]\n"));
		report_current();
		return 0;
	}

	save_EEPROM_current();
	report_current();
	return 0;
}

static int8_t
setup_sonar(uint8_t argc, const Menu::arg *argv)
{
	if (!strcmp_P(argv[1].str, PSTR("on"))) {
		g.sonar_enabled.set_and_save(true);

	} else if (!strcmp_P(argv[1].str, PSTR("off"))) {
		g.sonar_enabled.set_and_save(false);

	} else {
		Serial.printf_P(PSTR("\nOptions:[on, off]\n"));
		report_sonar();
		return 0;
	}

	report_sonar();
	return 0;
}

static int8_t
setup_mag_offset(uint8_t argc, const Menu::arg *argv)
{
	Serial.printf_P(PSTR("\nRotate/Pitch/Roll your ArduCopter until the offset variables stop changing.\n"));
	print_hit_enter();
	Serial.printf_P(PSTR("Starting in 3 secs.\n"));
	delay(3000);


	compass.init();	 // Initialization
	compass.set_orientation(MAGORIENTATION);		// set compass's orientation on aircraft
	//compass.set_offsets(0, 0, 0);					// set offsets to account for surrounding interference
	//int counter = 0;
	float _min[3], _max[3], _offset[3];

	while(1){
		static float min[3], _max[3], offset[3];
		if (millis() - fast_loopTimer > 100) {
			delta_ms_fast_loop 	= millis() - fast_loopTimer;
			fast_loopTimer		= millis();
			G_Dt 				= (float)delta_ms_fast_loop / 1000.f;


			compass.read();
			compass.calculate(0, 0);	// roll = 0, pitch = 0 for this example

			// capture min
			if(compass.mag_x < _min[0]) _min[0] = compass.mag_x;
			if(compass.mag_y < _min[1]) _min[1] = compass.mag_y;
			if(compass.mag_z < _min[2]) _min[2] = compass.mag_z;

			// capture max
			if(compass.mag_x > _max[0]) _max[0] = compass.mag_x;
			if(compass.mag_y > _max[1]) _max[1] = compass.mag_y;
			if(compass.mag_z > _max[2]) _max[2] = compass.mag_z;

			// calculate offsets
			offset[0] = -(_max[0] + _min[0]) / 2;
			offset[1] = -(_max[1] + _min[1]) / 2;
			offset[2] = -(_max[2] + _min[2]) / 2;

			// display all to user
			Serial.printf_P(PSTR("Heading: "));
			Serial.print(ToDeg(compass.heading));
			Serial.print("  \t(");
			Serial.print(compass.mag_x);
			Serial.print(",");
			Serial.print(compass.mag_y);
			Serial.print(",");
			Serial.print(compass.mag_z);
			Serial.print(")\t offsets(");
			Serial.print(offset[0]);
			Serial.print(",");
			Serial.print(offset[1]);
			Serial.print(",");
			Serial.print(offset[2]);
			Serial.println(")");

			if(Serial.available() > 0){

				//mag_offset_x = offset[0];
				//mag_offset_y = offset[1];
				//mag_offset_z = offset[2];

				//save_EEPROM_mag_offset();

				// set offsets to account for surrounding interference
				//compass.set_offsets(mag_offset_x, mag_offset_y, mag_offset_z);

				report_compass();
				break;
			}
		}
	}
}


/***************************************************************************/
// CLI utilities
/***************************************************************************/

void default_waypoint_info()
{
	g.waypoint_radius 		= 4; 	//TODO: Replace this quick fix with a real way to define wp_radius
	g.loiter_radius 		= 30; 	//TODO: Replace this quick fix with a real way to define loiter_radius
	save_EEPROM_waypoint_info();
}


void
default_nav()
{
	// nav control
	g.crosstrack_gain 				= XTRACK_GAIN * 100;
	g.crosstrack_entry_angle 		= XTRACK_ENTRY_ANGLE * 100;
	g.pitch_max 					= PITCH_MAX * 100;
	save_EEPROM_nav();
}

void
default_alt_hold()
{
	g.RTL_altitude.set(-1);
	save_EEPROM_alt_RTL();
}

void
default_frame()
{
	g.frame_type = PLUS_FRAME;
	save_EEPROM_frame();
}

void
default_current()
{
	g.milliamp_hours 		= 2000;
	g.current_enabled.set(false);
	save_EEPROM_current();
}

void
default_flight_modes()
{
	g.flight_modes[0] 			= FLIGHT_MODE_1;
	g.flight_modes[1] 			= FLIGHT_MODE_2;
	g.flight_modes[2] 			= FLIGHT_MODE_3;
	g.flight_modes[3] 			= FLIGHT_MODE_4;
	g.flight_modes[4] 			= FLIGHT_MODE_5;
	g.flight_modes[5] 			= FLIGHT_MODE_6;
	save_EEPROM_flight_modes();
}

void
default_throttle()
{
	g.throttle_min					= THROTTLE_MIN;
	g.throttle_max					= THROTTLE_MAX;
	g.throttle_cruise				= THROTTLE_CRUISE;
	g.throttle_fs_enabled			= THROTTLE_FAILSAFE;
	g.throttle_fs_action			= THROTTLE_FAILSAFE_ACTION;
	g.throttle_fs_value				= THROTTLE_FS_VALUE;
	save_EEPROM_throttle();
}

void default_logs()
{

	// convenience macro for testing LOG_* and setting LOGBIT_*
	#define LOGBIT(_s)	(LOG_ ## _s ? LOGBIT_ ## _s : 0)
	g.log_bitmask =
		LOGBIT(ATTITUDE_FAST)	|
		LOGBIT(ATTITUDE_MED)	|
		LOGBIT(GPS)				|
		LOGBIT(PM)				|
		LOGBIT(CTUN)			|
		LOGBIT(NTUN)			|
		LOGBIT(MODE)			|
		LOGBIT(RAW)				|
		LOGBIT(CMD)				|
		LOGBIT(CURRENT);
	#undef LOGBIT

	save_EEPROM_logs();
}


void
default_gains()
{
	// acro, angular rate
	g.pid_acro_rate_roll.kP(ACRO_RATE_ROLL_P);
	g.pid_acro_rate_roll.kI(ACRO_RATE_ROLL_I);
	g.pid_acro_rate_roll.kD(0);
	g.pid_acro_rate_roll.imax(ACRO_RATE_ROLL_IMAX * 100);

	g.pid_acro_rate_pitch.kP(ACRO_RATE_PITCH_P);
	g.pid_acro_rate_pitch.kI(ACRO_RATE_PITCH_I);
	g.pid_acro_rate_pitch.kD(0);
	g.pid_acro_rate_pitch.imax(ACRO_RATE_PITCH_IMAX * 100);

	g.pid_acro_rate_yaw.kP(ACRO_RATE_YAW_P);
	g.pid_acro_rate_yaw.kI(ACRO_RATE_YAW_I);
	g.pid_acro_rate_yaw.kD(0);
	g.pid_acro_rate_yaw.imax(ACRO_RATE_YAW_IMAX * 100);


	// stabilize, angle error
	Serial.printf("b4 %4.2f, ",g.pid_stabilize_roll.kP());
	g.pid_stabilize_roll.kP(STABILIZE_ROLL_P);
	Serial.printf("L8R %4.2f\n ",g.pid_stabilize_roll.kP());
	g.pid_stabilize_roll.kI(STABILIZE_ROLL_I);
	g.pid_stabilize_roll.kD(0);
	g.pid_stabilize_roll.imax(STABILIZE_ROLL_IMAX * 100);

	g.pid_stabilize_pitch.kP(STABILIZE_PITCH_P);
	g.pid_stabilize_pitch.kI(STABILIZE_PITCH_I);
	g.pid_stabilize_pitch.kD(0);
	g.pid_stabilize_pitch.imax(STABILIZE_PITCH_IMAX * 100);

	// YAW hold
	g.pid_yaw.kP(YAW_P);
	g.pid_yaw.kI(YAW_I);
	g.pid_yaw.kD(0);
	g.pid_yaw.imax(YAW_IMAX * 100);


	// custom dampeners
	// roll pitch
	g.stabilize_dampener 	= STABILIZE_DAMPENER;

	//yaw
	g.hold_yaw_dampener		= HOLD_YAW_DAMPENER;

	// navigation
	g.pid_nav_lat.kP(NAV_P);
	g.pid_nav_lat.kI(NAV_I);
	g.pid_nav_lat.kD(NAV_D);
	g.pid_nav_lat.imax(NAV_IMAX);

	g.pid_nav_lon.kP(NAV_P);
	g.pid_nav_lon.kI(NAV_I);
	g.pid_nav_lon.kD(NAV_D);
	g.pid_nav_lon.imax(NAV_IMAX);

	g.pid_baro_throttle.kP(THROTTLE_BARO_P);
	g.pid_baro_throttle.kI(THROTTLE_BARO_I);
	g.pid_baro_throttle.kD(THROTTLE_BARO_D);
	g.pid_baro_throttle.imax(THROTTLE_BARO_IMAX);

	g.pid_sonar_throttle.kP(THROTTLE_SONAR_P);
	g.pid_sonar_throttle.kI(THROTTLE_SONAR_I);
	g.pid_sonar_throttle.kD(THROTTLE_SONAR_D);
	g.pid_sonar_throttle.imax(THROTTLE_SONAR_IMAX);

	save_EEPROM_PID();
	Serial.printf("EL8R %4.2f\n ",g.pid_stabilize_roll.kP());

}



/***************************************************************************/
// CLI utilities
/***************************************************************************/

void report_current()
{
	//print_blanks(2);
	read_EEPROM_current();
	Serial.printf_P(PSTR("Current Sensor\n"));
	print_divider();
	print_enabled(g.current_enabled.get());

	Serial.printf_P(PSTR("mah: %d"),(int)g.milliamp_hours.get());
	print_blanks(2);
}

void report_sonar()
{
	//print_blanks(2);
	g.sonar_enabled.load();
	Serial.printf_P(PSTR("Sonar Sensor\n"));
	print_divider();
	print_enabled(g.sonar_enabled.get());
	print_blanks(2);
}


void report_frame()
{
	//print_blanks(2);
	read_EEPROM_frame();
	Serial.printf_P(PSTR("Frame\n"));
	print_divider();


	if(g.frame_type == X_FRAME)
		Serial.printf_P(PSTR("X "));
	else if(g.frame_type == PLUS_FRAME)
		Serial.printf_P(PSTR("Plus "));
	else if(g.frame_type == TRI_FRAME)
		Serial.printf_P(PSTR("TRI "));
	else if(g.frame_type == HEXA_FRAME)
		Serial.printf_P(PSTR("HEXA "));

	Serial.printf_P(PSTR("frame (%d)"), (int)g.frame_type);
	print_blanks(2);
}

void report_radio()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Radio\n"));
	print_divider();
	// radio
	read_EEPROM_radio();
	print_radio_values();
	print_blanks(2);
}

void report_gains()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Gains\n"));
	print_divider();

	read_EEPROM_PID();
	// Acro
	Serial.printf_P(PSTR("Acro:\nroll:\n"));
	print_PID(&g.pid_acro_rate_roll);
	Serial.printf_P(PSTR("pitch:\n"));
	print_PID(&g.pid_acro_rate_pitch);
	Serial.printf_P(PSTR("yaw:\n"));
	print_PID(&g.pid_acro_rate_yaw);

	// Stabilize
	Serial.printf_P(PSTR("\nStabilize:\nroll:\n"));
	print_PID(&g.pid_stabilize_roll);
	Serial.printf_P(PSTR("pitch:\n"));
	print_PID(&g.pid_stabilize_pitch);
	Serial.printf_P(PSTR("yaw:\n"));
	print_PID(&g.pid_yaw);

	Serial.printf_P(PSTR("Stabilize dampener: %4.3f\n"), (float)g.stabilize_dampener);
	Serial.printf_P(PSTR("Yaw Dampener: %4.3f\n\n"), (float)g.hold_yaw_dampener);

	// Nav
	Serial.printf_P(PSTR("Nav:\nlat:\n"));
	print_PID(&g.pid_nav_lat);
	Serial.printf_P(PSTR("long:\n"));
	print_PID(&g.pid_nav_lon);
	Serial.printf_P(PSTR("baro throttle:\n"));
	print_PID(&g.pid_baro_throttle);
	Serial.printf_P(PSTR("sonar throttle:\n"));
	print_PID(&g.pid_sonar_throttle);
	print_blanks(2);
}

void report_xtrack()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Crosstrack\n"));
	print_divider();
	// radio
	read_EEPROM_nav();
	Serial.printf_P(PSTR("XTRACK: %4.2f\n"
						 "XTRACK angle: %d\n"
						 "PITCH_MAX: %ld"),
						 (float)g.crosstrack_gain,
						 (int)g.crosstrack_entry_angle,
						 (long)g.pitch_max);
	print_blanks(2);
}

void report_throttle()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Throttle\n"));
	print_divider();

	read_EEPROM_throttle();
	Serial.printf_P(PSTR("min: %d\n"
						 "max: %d\n"
						 "cruise: %d\n"
						 "failsafe_enabled: %d\n"
						 "failsafe_value: %d"),
						 (int)g.throttle_min,
						 (int)g.throttle_max,
						 (int)g.throttle_cruise,
						 (int)g.throttle_fs_enabled,
						 (int)g.throttle_fs_value);
	print_blanks(2);
}

void report_imu()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("IMU\n"));
	print_divider();

	print_gyro_offsets();
	print_accel_offsets();
	print_blanks(2);
}

void report_compass()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Compass\n"));
	print_divider();

	read_EEPROM_compass();
	//read_EEPROM_compass_declination();
	//read_EEPROM_compass_offset();

	print_enabled(g.compass_enabled);

	// mag declination
	Serial.printf_P(PSTR("Mag Delination: %4.4f\n"),
							degrees(compass.get_declination()));

	Vector3f offsets = compass.get_offsets();

	// mag offsets
	Serial.printf_P(PSTR("Mag offsets: %4.4f, %4.4f, %4.4f"),
							offsets.x,
							offsets.y,
							offsets.z);
	print_blanks(2);
}


void report_flight_modes()
{
	//print_blanks(2);
	Serial.printf_P(PSTR("Flight modes\n"));
	print_divider();
	read_EEPROM_flight_modes();

	for(int i = 0; i < 6; i++ ){
		print_switch(i, g.flight_modes[i]);
	}
	print_blanks(2);
}

/***************************************************************************/
// CLI utilities
/***************************************************************************/

void
print_PID(PID * pid)
{
	Serial.printf_P(PSTR("P: %4.3f, I:%4.3f, D:%4.3f, IMAX:%ld\n"), pid->kP(), pid->kI(), pid->kD(), (long)pid->imax());
}

void
print_radio_values()
{
	Serial.printf_P(PSTR("CH1: %d | %d\n"), (int)g.rc_1.radio_min, (int)g.rc_1.radio_max);
	Serial.printf_P(PSTR("CH2: %d | %d\n"), (int)g.rc_2.radio_min, (int)g.rc_2.radio_max);
	Serial.printf_P(PSTR("CH3: %d | %d\n"), (int)g.rc_3.radio_min, (int)g.rc_3.radio_max);
	Serial.printf_P(PSTR("CH4: %d | %d\n"), (int)g.rc_4.radio_min, (int)g.rc_4.radio_max);
	Serial.printf_P(PSTR("CH5: %d | %d\n"), (int)g.rc_5.radio_min, (int)g.rc_5.radio_max);
	Serial.printf_P(PSTR("CH6: %d | %d\n"), (int)g.rc_6.radio_min, (int)g.rc_6.radio_max);
	Serial.printf_P(PSTR("CH7: %d | %d\n"), (int)g.rc_7.radio_min, (int)g.rc_7.radio_max);
	Serial.printf_P(PSTR("CH8: %d | %d\n"), (int)g.rc_8.radio_min, (int)g.rc_8.radio_max);
}

void
print_switch(byte p, byte m)
{
	Serial.printf_P(PSTR("Pos %d: "),p);
	Serial.println(flight_mode_strings[m]);
}

void
print_done()
{
	Serial.printf_P(PSTR("\nSaved Settings\n\n"));
}

void
print_blanks(int num)
{
	while(num > 0){
		num--;
		Serial.println("");
	}
}

void
print_divider(void)
{
	for (int i = 0; i < 40; i++) {
		Serial.print("-");
	}
	Serial.println("");
}


// for reading in vales for mode switch
boolean
radio_input_switch(void)
{
	static int8_t bouncer = 0;

	if (int16_t(g.rc_1.radio_in - g.rc_1.radio_trim) > 100) {
	    bouncer = 10;
	}
	if (int16_t(g.rc_1.radio_in - g.rc_1.radio_trim) < -100) {
	    bouncer = -10;
	}
	if (bouncer >0) {
	    bouncer --;
	}
	if (bouncer <0) {
	    bouncer ++;
	}

	if (bouncer == 1 || bouncer == -1) {
	    return bouncer;
	} else {
	    return 0;
	}
}


void zero_eeprom(void)
{
	byte b;
	Serial.printf_P(PSTR("\nErasing EEPROM\n"));
	for (int i = 0; i < EEPROM_MAX_ADDR; i++) {
		eeprom_write_byte((uint8_t *) i, b);
	}
	Serial.printf_P(PSTR("done\n"));
}


void print_enabled(boolean b)
{
	if(b)
		Serial.printf_P(PSTR("en"));
	else
		Serial.printf_P(PSTR("dis"));
	Serial.printf_P(PSTR("abled\n"));
}

void
print_accel_offsets(void)
{
	Serial.println("jason");
	Serial.println(imu.ax(), 2);
	Serial.println((float)imu.ax(),2);
	Serial.println(imu.ax(), DEC);
	Serial.println("jason");

	Serial.printf(PSTR("Accel offsets: %4.2f, %4.2f, %4.2f\n"),
						(float)imu.ax(),
						(float)imu.ay(),
						(float)imu.az()
	);
}

void
print_gyro_offsets(void)
{
	Serial.println("jasong");
	Serial.println(imu.gx(), 2);
	Serial.println((float)imu.gx(),2);
	Serial.println(imu.gx(), DEC);
	Serial.println("jasong");

	Serial.printf(PSTR("Gyro offsets: %4.2f, %4.2f, %4.2f\n"),
						(float)imu.gx(),
						(float)imu.gy(),
						(float)imu.gz()
	);
}


