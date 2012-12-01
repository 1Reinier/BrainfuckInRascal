module Eval

import Prelude;
import Abstract;
import Syntax;
//import Load;

alias Tape = list[int];
alias ENV = tuple[int pointer, Tape array, str input, str output];

public ENV initEnv(){
	pointer = 0;
	//Make Array smaller for memory purposes, add extra cells as needed. "lazy" implementation
	array = [0,0];
	str input = "";
	str output = "";
	return <pointer, array, input, output>;
}

// Evaluate program

public str evalProgram(PROGRAM P){
	if(program(list[STATEMENT] stats, str input) := P){
		env = initEnv();
		env.input = input;
		return evalStats(stats, env).output;
  	} 
  	else 
  		if(program(list[STATEMENT] stats) := P){
			env = initEnv();
		return evalStats(stats, env).output;
  	} 
   	throw "Program does not match the correct form";
}
	
// Evaluate a list of statements

public ENV evalStats(list[STATEMENT] stats, ENV env){
	for(s <- stats)
		env = evalStat(s, env);
	return env;
}

// Evaluate individual statements

public ENV evalStat(whileStat(list[STATEMENT] body), ENV env){
	while(env.array[env.pointer] != 0){
		env = evalStats(body, env);
	}
	return env;
}

public ENV evalStat(incr(), ENV env){
	env.array[env.pointer] += 1;
	return env;
}

public ENV evalStat(decr(), ENV env){
	env.array[env.pointer] -= 1;
	return env;
}

public ENV evalStat(goleft(), ENV env){
	if(env.pointer > 0){
		env.pointer -= 1;
		return env;
	}
	else
		throw "pointer out of bounds";
}

public ENV evalStat(goright(), ENV env){
	if(env.pointer < 30000){
		if(size(env.array) <= env.pointer+1){
			env.array += [0];
			}
			env.pointer += 1;
			return env;
	}
	else
		throw "pointer out of bounds";
}

public ENV evalStat(read(), ENV env){
	if(env.input == ""){ 
		env.array[env.pointer] = 0;
		return env;
	}
	else {
		env.array[env.pointer] = chars(env.input)[0];
		env.input = substring(env.input, 1);
		return env;
	}
}

public ENV evalStat(output(), ENV env){
	env.output += stringChar(env.array[env.pointer]);
	return env;
}

// Tests:
public PROGRAM  load(str txt) = implode(#PROGRAM, parse(#Program, txt));

test bool HelloWorld(){
	 try load("\>+++++++++[\<++++++++\>-]\<.\>+++++++[\<++++\>-]\<+.+++++ ++..+++.\>\>\>++++++++
	 		[\<++++\>-]\<.\>\>\>++++++++++[\<+++++ ++++\>-]\<---.\<\<\<\<.+++.------.--------.
	 		\>\>+.");
	 catch: return false;
	 return true;
	 }
	 	
test bool testEval(){
	str code = "\>+++++++++[\<++++++++\>-]\<.\>+++++++[\<++++\>-]\<+.+++++ ++..+++.\>\>\>++++++++[\<++++\>-]\<.\>\>\>++++++++++[\<+++++ ++++\>-]\<---.\<\<\<\<.+++.------.--------.\>\>+.";
	return evalProgram(load(code)) == "Hello World!";
	}