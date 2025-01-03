# Copyright 2024 Christoforos-Marios Mamaloukas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

@icon("res://assets/img/basic_enemy_stats.svg")
class_name BasicEnemyStats
extends Resource

@export_range(0, 10, 0.1, "suffix:s") var move_decision_wait: float: ## How much to wait for a movement decision
	get: return move_decision_wait if move_decision_wait > 0 else 1.0/Engine.physics_ticks_per_second # zero means "very very little time" and "very very little time" means 1 frame here
	set(value): move_decision_wait = max(0, value) # negatives aren't allowed
