// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

#macro spBatchMap global.sPartVertexBatchMap
#macro spUniMap global.sPartUniformMap
#macro spUniGrid global.sPartUniformGrid
#macro spSprMap global.sPartSpriteMap
#macro spSystems global.sPartSystemList
#macro spMeshes global.sPartMeshList
global.sPartVertexBatchMap = ds_map_create();
global.sPartUniformMap = ds_map_create();
global.sPartUniformGrid = ds_grid_create(0, 0);
global.sPartSpriteMap = ds_map_create();
global.sPartSystemList = ds_list_create();
global.sPartMeshList = ds_list_create();

enum sPartUni
{
	batchInd, partNum,
	emStartMat, emEndMat, emLifeSpan, emShapeDistrBurst, emID, emPartsPerStep, emTimeAlive, emSector , emMeshOffset,
	partSprOrig, partSprSettings, partLife, partSize, partSizeClamp, partAngle, partAngleRel, partSpd, partDir, partDirRad, partGrav, partCol, partColType,
	parentPartLife, parentPartSpd, parentPartDir, parentPartGrav, parentPartDirRad, parentPartSpawnNum,  
	partMeshRotAxis, partMeshAmbCol, partMeshLightCol, partMeshLightDir, step, partAlphaTestRef,
	Num
}

//Create billboard particle format
vertex_format_begin();
vertex_format_add_color();
global.sPartFormat = vertex_format_end();

//Create mesh particle format
vertex_format_begin();
vertex_format_add_color();
vertex_format_add_color();
global.sPartMeshFormat = vertex_format_end();

function spart_clear()
{
	/*
		Removes all particle systems, emitters, types and sprites that have been created with the sPart system
	*/
	//Destroy all particle systems
	repeat (ds_list_size(spSystems))
	{
		spSystems[| 0].destroy();
		ds_list_delete(spSystems, 0);
	}
	
	//Destroy all mesh particle vbuffers
	repeat (ds_list_size(spMeshes))
	{
		vertex_delete_buffer(spMeshes[| 0]);
		ds_list_delete(spMeshes, 0);
	}
	
	//Delete all sprites
	var spr = ds_map_find_first(spSprMap);
	while (!is_undefined(spr))
	{
		sprite_delete(spSprMap[? spr]);
		spr = ds_map_find_next(spSprMap, spr);
	}
	ds_map_clear(spSprMap);
	
	//Destroy all vertex buffers
	var vbuff = ds_map_find_first(spBatchMap);
	while (!is_undefined(vbuff))
	{
		vertex_delete_buffer(spBatchMap[? vbuff]);
		vbuff = ds_map_find_next(spBatchMap, vbuff);
	}
	ds_map_clear(spBatchMap);
	
	//Remove all shader uniforms
	ds_map_clear(spUniMap);
	ds_grid_resize(spUniGrid, 0, 0);
}

/// @func spart_system(batchSizeArray)
function spart_system(_batchSizeArray) constructor
{
	if (is_array(_batchSizeArray))
	{
		batchSizeArray = _batchSizeArray;
	}
	else
	{
		batchSizeArray = [256];
	}
	
	time = 0;
	dynamic = false;
	drawCalls = 0;
	particleNum = 0;
	emitterList = ds_list_create(); //A list containing all the emitters of this particle system
	stepEmitterList = ds_list_create(); //A list containing all the step secondary emitters of this particle system
	deathEmitterList = ds_list_create(); //A list containing all the death secondary emitters of this particle system
	activeEmitterList = ds_list_create(); //A list containing all the actively emitting emitters of this particle system
	
	regularShader = sh_spart;//asset_get_index("sh_spart");
	secondaryShader = sh_spart_sec;//asset_get_index("sh_spart_sec");
	meshShader = sh_spart_mesh;//asset_get_index("sh_spart_mesh");
	emitterMeshShader = asset_get_index("sh_spart_emittermesh");
	
	dynamicInterval = 1;
	
	/// @func destroy()
	static destroy = function()
	{
		ds_list_destroy(emitterList);
		ds_list_destroy(stepEmitterList);
		ds_list_destroy(deathEmitterList);
		ds_list_destroy(activeEmitterList);
	}
	
	/// @func updateVbuffs()
	static updateVbuffs = function()
	{
		var num = array_length(batchSizeArray);
		vertexBatchArray = array_create(num);
		var i, j, k, particlesPerBatch, mBuff, k;
		for (k = 0; k < num; k ++)
		{
			particlesPerBatch = batchSizeArray[k];
	
			//If this vertex buffer already exists, load the existing one
			if (!is_undefined(spBatchMap[? particlesPerBatch]))
			{
				vertexBatchArray[k] = spBatchMap[? particlesPerBatch];
				continue;
			}
			mBuff = buffer_create(particlesPerBatch * 24, buffer_fast, 1);
			for (i = 0; i < particlesPerBatch; i ++)
			{
				for (j = 2; j >= 0; j --)
				{
					buffer_write(mBuff, buffer_u8, i mod 256);
					buffer_write(mBuff, buffer_u8, (i div 256) mod 256);
					buffer_write(mBuff, buffer_u8, i div (256 * 256));
					buffer_write(mBuff, buffer_u8, j);
				}
				for (j = 1; j < 4; j ++)
				{
					buffer_write(mBuff, buffer_u8, i mod 256);
					buffer_write(mBuff, buffer_u8, (i div 256) mod 256);
					buffer_write(mBuff, buffer_u8, i div (256 * 256));
					buffer_write(mBuff, buffer_u8, j);
				}
			}
			vertexBatchArray[k] = vertex_create_buffer_from_buffer(mBuff, global.sPartFormat);
			vertex_freeze(vertexBatchArray[k]);
			buffer_delete(mBuff);
			spBatchMap[? particlesPerBatch] = vertexBatchArray[k];
		}
	}

	updateVbuffs();
	
	static step = function(timeIncrement)
	{
		//Loop through active emitters
		var i = ds_list_size(activeEmitterList);
		repeat (i div 2)
		{
			var emitter = activeEmitterList[| --i];
			-- i;
	
			/////////////////////////////////////////////
			//Retire active emitters that have lived longer than their life span
			if (emitter.type == sPartEmitterType.Stream && time >= emitter.creationTime + emitter.lifeSpan)
			{
				emitter.retire(true);
			}
	
			/////////////////////////////////////////////
			//Delete retired emitters whose particles are all dead
			if (emitter.type == sPartEmitterType.Retired && time >= emitter.timeOfDeath)
			{
				emitter.destroy();
			}
		}
	}
	
	/// @func draw()
	static draw = function(timeIncrement)
	{
		particleNum = 0;
		drawCalls = 0;
		time += timeIncrement;
		
		//Initialize temporary variables
		var shader, uniInd, i;
		var stepNum = ds_list_size(stepEmitterList);
		var deathNum = ds_list_size(deathEmitterList);
		var emitterNum = ds_list_size(activeEmitterList);
		
		gpu_push_state();
		
		//Draw secondary particles
		if (stepNum || deathNum)
		{
			if (secondaryShader >= 0 && shader_is_compiled(secondaryShader))
			{
				shader_set(secondaryShader);
				uniInd = spart_get_uniform_index(secondaryShader);
		
				/////////////////////////////////////////////
				//Draw step particle effects
				var prevPartType = -1;
				var i = stepNum;
				repeat (i div 2)
				{
					var emitter = stepEmitterList[| --i];
					var partType = stepEmitterList[| --i];
					if (partType != prevPartType)
					{
						prevPartType = partType;
						partType.setUniforms(uniInd);
						var parentType = emitter.partType;
						parentType.setParentUniforms(uniInd, true);
						var particlesPerParent = ceil(parentType.stepNumber * min(parentType.life[1], partType.life[1]));
					}
					var parentPartNum = min(parentType.life[1] + partType.life[1], emitter.lifeSpan, time - emitter.creationTime) * emitter.particlesPerStep;
					var partNum = ceil(particlesPerParent * parentPartNum);
					emitter.submit(partType, uniInd, partNum);
				}
		
				/////////////////////////////////////////////
				//Draw death particle effects
				var prevPartType = -1;
				var i = deathNum;
				repeat (i div 2)
				{
					var emitter = deathEmitterList[| --i];
					var partType = deathEmitterList[| --i];
					if (partType != prevPartType)
					{
						prevPartType = partType;
						partType.setUniforms(uniInd);
						var parentType = emitter.partType;
						parentType.setParentUniforms(uniInd, false);
						var particlesPerParent = parentType.deathNumber;
					}
					var parentPartNum = min(parentType.life[1] + partType.life[1] - parentType.life[0], emitter.lifeSpan, time - emitter.creationTime) * emitter.particlesPerStep;
					var partNum = ceil(particlesPerParent * parentPartNum);
					emitter.submit(partType, uniInd, partNum);
				}
			}
		}
		
		//Loop through active emitters
		var prevPartType = -1;
		var i = emitterNum;
		repeat (i div 2)
		{
			var emitter = activeEmitterList[| --i];
			var partType = activeEmitterList[| --i];
			
			/////////////////////////////////////////////
			//Retire active emitters that have lived longer than their life span
			if (emitter.type == sPartEmitterType.Stream && time >= emitter.creationTime + emitter.lifeSpan)
			{
				emitter.retire(true);
			}
	
			/////////////////////////////////////////////
			//Delete retired emitters whose particles are all dead
			if (emitter.type == sPartEmitterType.Retired && time >= emitter.timeOfDeath)
			{
				emitter.destroy();
				continue;
			}
	
			/////////////////////////////////////////////
			//Draw regular particles
			if (partType != prevPartType)
			{
				shader = (partType.meshEnabled ? meshShader : regularShader);
				if (shader < 0){continue;} //Shader does not exist, can't draw this emitter
				shader_set(shader);
				uniInd = spart_get_uniform_index(shader);
				partType.setUniforms(uniInd);
				prevPartType = partType;
			}
			var partNum = ceil(min(partType.life[1], emitter.lifeSpan, time - emitter.creationTime) * emitter.particlesPerStep);
			emitter.submit(partType, uniInd, partNum);
		}
		
		shader_reset();
		gpu_pop_state();
	}

	/// @func setDynamicInterval(interval)
	static setDynamicInterval = function(interval)
	{
		dynamicInterval = interval;
	}
}

function spart_get_uniform_index(shader) 
{
	/*
		Returns the uniform index of the given shader.
		If the shader has not been indexed previously, get the relevant shader uniforms.
	
		Script created by TheSnidr
		www.TheSnidr.com
	*/
	var i = spUniMap[? shader];
	if is_undefined(i)
	{
		i = ds_map_size(spUniMap);
		spUniMap[? shader] = i;
	
		if ds_grid_height(spUniGrid) <= i
		{
			ds_grid_resize(spUniGrid, sPartUni.Num, i+1);
		}
	
		//Batch info
		spUniGrid[# sPartUni.batchInd, i] = shader_get_uniform(shader, "u_batchInd")
		spUniGrid[# sPartUni.partNum, i] = shader_get_uniform(shader, "u_partNum")
	
		//Emitter uniforms
		spUniGrid[# sPartUni.emStartMat, i] = shader_get_uniform(shader, "u_EmStartMat");
		spUniGrid[# sPartUni.emEndMat, i] = shader_get_uniform(shader, "u_EmEndMat");
		spUniGrid[# sPartUni.emLifeSpan, i] = shader_get_uniform(shader, "u_EmLifeSpan");
		spUniGrid[# sPartUni.emTimeAlive, i] = shader_get_uniform(shader, "u_EmTimeAlive");
		spUniGrid[# sPartUni.emShapeDistrBurst, i] = shader_get_uniform(shader, "u_EmShapeDistrBurst");
		spUniGrid[# sPartUni.emID, i] = shader_get_uniform(shader, "u_EmID");
		spUniGrid[# sPartUni.emPartsPerStep, i] = shader_get_uniform(shader, "u_EmPtsPerStep");
		spUniGrid[# sPartUni.emSector, i] = shader_get_uniform(shader, "u_EmSector");
		spUniGrid[# sPartUni.emMeshOffset, i] = shader_get_uniform(shader, "u_EmMeshOffset");
	
		//Particle type uniforms
		spUniGrid[# sPartUni.partDir, i] = shader_get_uniform(shader, "u_PtDir");
		spUniGrid[# sPartUni.partLife, i] = shader_get_uniform(shader, "u_PtLife");
		spUniGrid[# sPartUni.partAngle, i] = shader_get_uniform(shader, "u_PtAngle");
		spUniGrid[# sPartUni.partSize, i] = shader_get_uniform(shader, "u_PtSize");
		spUniGrid[# sPartUni.partSizeClamp, i] = shader_get_uniform(shader, "u_PtSizeClamp");
		spUniGrid[# sPartUni.partSpd, i] = shader_get_uniform(shader, "u_PtSpd");
		spUniGrid[# sPartUni.partGrav, i] = shader_get_uniform(shader, "u_PtGravVec");
		spUniGrid[# sPartUni.partAngleRel, i] = shader_get_uniform(shader, "u_PtAngleRel");
		spUniGrid[# sPartUni.partDirRad, i] = shader_get_uniform(shader, "u_PtDirRadial");
		spUniGrid[# sPartUni.partCol, i] = shader_get_uniform(shader, "u_PtCol");
		spUniGrid[# sPartUni.partColType, i] = shader_get_uniform(shader, "u_PtColType");
		spUniGrid[# sPartUni.partSprOrig, i] = shader_get_uniform(shader, "u_PtSprOrig");
		spUniGrid[# sPartUni.partSprSettings, i] = shader_get_uniform(shader, "u_PtSprSettings");
		spUniGrid[# sPartUni.partAlphaTestRef, i] = shader_get_uniform(shader, "u_PtAlphaTestRef");

		//Secondary particle uniforms
		spUniGrid[# sPartUni.step, i] = shader_get_uniform(shader, "u_step");
		spUniGrid[# sPartUni.parentPartLife, i] = shader_get_uniform(shader, "u_parPtLife");
		spUniGrid[# sPartUni.parentPartSpd, i] = shader_get_uniform(shader, "u_parPtSpd");
		spUniGrid[# sPartUni.parentPartDir, i] = shader_get_uniform(shader, "u_parPtDir");
		spUniGrid[# sPartUni.parentPartGrav, i] = shader_get_uniform(shader, "u_parPtGravVec");
		spUniGrid[# sPartUni.parentPartDirRad, i] = shader_get_uniform(shader, "u_parPtDirRadial");
		spUniGrid[# sPartUni.parentPartSpawnNum, i] = shader_get_uniform(shader, "u_parPtSpawnNum");

		//Mesh particle uniforms
		spUniGrid[# sPartUni.partMeshRotAxis, i] = shader_get_uniform(shader, "u_PtMeshRotAxis");
		spUniGrid[# sPartUni.partMeshAmbCol, i] = shader_get_uniform(shader, "u_PtMeshAmbientCol");
		spUniGrid[# sPartUni.partMeshLightCol, i] = shader_get_uniform(shader, "u_PtMeshLightCol");
		spUniGrid[# sPartUni.partMeshLightDir, i] = shader_get_uniform(shader, "u_PtMeshLightDir");
	}

	return i;
}

function spart_matrix_build(x, y, z, xrotation, yrotation, zrotation, xscale, yscale, zscale)
{
	/*
		This is an alternative to the regular matrix_build.
		The regular function will rotate first and then scale, which can result in weird shearing.
		I have no idea why they did it this way.
		This script does it properly so that no shearing is applied even if you both rotate and scale non-uniformly.
	*/
	var M = matrix_build(x, y, z, xrotation, yrotation, zrotation, 1, 1, 1);
	return spart_matrix_scale(M, xscale, yscale, zscale);
}

function spart_matrix_scale(M, toScale, siScale, upScale)
{
	/*
		Scaled the given matrix along its own axes
	*/
	M[@ 0] *= toScale;
	M[@ 1] *= toScale;
	M[@ 2] *= toScale;
	M[@ 4] *= siScale;
	M[@ 5] *= siScale;
	M[@ 6] *= siScale;
	M[@ 8] *= upScale;
	M[@ 9] *= upScale;
	M[@ 10]*= upScale;
	return M;
}

function spart_matrix_orthogonalize(M)
{
	/*
		This makes sure the three vectors of the given matrix are all unit length
		and perpendicular to each other, using the up direciton as master.
		GameMaker does something similar when creating a lookat matrix. People often use [0, 0, 1]
		as the up direction, but this vector is not used directly for creating the view matrix; rather, 
		it's being used as reference, and the entire view matrix is being orthogonalized to the looking direction.
	*/
	var l = M[8] * M[8] + M[9] * M[9] + M[10] * M[10];
	if (l == 0){return false;}
	l = 1 / sqrt(l);
	M[@ 8] *= l;
	M[@ 9] *= l;
	M[@ 10]*= l;
	
	M[@ 4] = M[9] * M[2] - M[10]* M[1];
	M[@ 5] = M[10]* M[0] - M[8] * M[2];
	M[@ 6] = M[8] * M[1] - M[9] * M[0];
	var l = M[4] * M[4] + M[5] * M[5] + M[6] * M[6];
	if (l == 0){return false;}
	l = 1 / sqrt(l);
	M[@ 4] *= l;
	M[@ 5] *= l;
	M[@ 6] *= l;
	
	//The last vector is automatically normalized, since the two other vectors now are perpendicular unit vectors
	M[@ 0] = M[10]* M[5] - M[9] * M[6];
	M[@ 1] = M[8] * M[6] - M[10]* M[4];
	M[@ 2] = M[9] * M[4] - M[8] * M[5];
	
	return true;
}

function spart_load_obj_to_buffer(filename) 
{
	var buffer = buffer_load(filename);
	if (buffer == -1)
	{
		show_debug_message("Script load_obj_to_buffer: Failed to load model " + string(filename)); 
		return -1;
	}
	show_debug_message("Script load_obj_to_buffer: Loading obj file " + string(filename));
	
	var contents = buffer_read(buffer, buffer_text);
	var lines = string_split(contents, "\n");
	var num = array_length(lines);

	//Create the necessary arrays
	var V = array_create(num);
	var N = array_create(num);
	var T = array_create(num);
	var F = array_create(num);
	var V_num = 0;
	var N_num = 0;
	var T_num = 0;
	var F_num = 0;

	//Read .obj as text
	var str, type;
	for (var i = 0; i < num; ++i)
	{
		var this_line = string_delete(lines[i], string_length(lines[i]), 1);
		if (this_line == "") continue;
		
		var tokens = string_split(this_line, " ");
		//Different types of information in the .obj starts with different headers
		switch tokens[0]
		{
			//Load vertex positions
			case "v":
				V[V_num ++] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			//Load vertex normals
			case "vn":
				N[N_num ++] = [real(tokens[1]), real(tokens[2]), real(tokens[3])];
				break;
			//Load vertex texture coordinates
			case "vt":
				T[T_num ++] = [real(tokens[1]), real(tokens[2])];
				break;
			//Load faces
			case "f":
				var vert_num = array_length(tokens) - 1;
				var face_verts = array_create(vert_num);
				for (var j = 0; j < vert_num; ++j)
				{
					var info = tokens[j + 1];
					var indices = string_split(info, "/");
					if (string_count("/", info) == 2 && string_count("//", info) == 0)
					{	//If the vertex contains a position, texture coordinate and normal
						face_verts[j] = [real(indices[0]) - 1, real(indices[2]) - 1, real(indices[1]) - 1];
					}
					else if (string_count("/", info) == 1)
					{	//If the vertex contains a position and a texture coordinate
						face_verts[j] = [real(indices[0]) - 1, 0, real(indices[1]) - 1];
					}
					else if (string_count("/", info) == 0)
					{	//If the vertex only contains a position
						face_verts[j] = [real(indices[0]) - 1, 0, 0];
					}
					else if (string_count("//", info) == 1)
					{	//If the vertex contains a position and normal
						face_verts[j] = [real(indices[0]) - 1, real(indices[2]) - 1, 0];
					}
				}
				
				//Add vertices in a triangle fan
				for (var j = 0; j <= vert_num - 3; ++j)
				{
					for (var k = 2; k >= 0; --k)
					{
						var index = (j + k) * (k > 0);
						F[F_num ++] = face_verts[index];
					}
				}
				break;
		}
	}
	buffer_delete(buffer);

	//Loop through the loaded information and generate a model
	var vnt, vertNum, mbuff, vbuff, v, n, t;
	mbuff = buffer_create(F_num * (9 * 4), buffer_fixed, 1);
	for (var f = 0; f < F_num; f ++)
	{
		vnt = F[f];
		
		//Add the vertex to the model buffer
		v = V[vnt[0]];
		if !is_array(v){v = [0, 0, 0];}
		buffer_write(mbuff, buffer_f32, v[0]);
		buffer_write(mbuff, buffer_f32, v[2]);
		buffer_write(mbuff, buffer_f32, v[1]);
		
		n = N[vnt[1]];
		if !is_array(n){n = [0, 0, 1];}
		buffer_write(mbuff, buffer_f32, n[0]);
		buffer_write(mbuff, buffer_f32, n[2]);
		buffer_write(mbuff, buffer_f32, n[1]);
		
		t = T[vnt[2]];
		if !is_array(t){t = [0, 0];}
		buffer_write(mbuff, buffer_f32, t[0]);
		buffer_write(mbuff, buffer_f32, 1-t[1]);
		
		buffer_write(mbuff, buffer_u8, 255);
		buffer_write(mbuff, buffer_u8, 255);
		buffer_write(mbuff, buffer_u8, 255);
		buffer_write(mbuff, buffer_u8, 255);
	}
	show_debug_message("Script load_obj_to_buffer: Successfully loaded obj " + string(filename));
	return mbuff
}