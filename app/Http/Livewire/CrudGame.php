<?php

namespace App\Http\Livewire;

use App\Models\Place;
use App\Models\Team;
use Carbon\Carbon;
use DateTime;
use Livewire\Component;

class CrudGame extends Component{
    public $results = array();

    public $dategame,$places,$date,$idprueba;
    public $timeinit="07:00";
    public $timegame=30;

    public function render(){
        $this->dategame=Carbon::now()->toDateString();
        $this->places=Place::all();
        return view('livewire.crud-game');
    }

    public function random_teams(){
        $teams=Team::where('type','Masculino')
                    ->where('status','Activo')->get('name');

        foreach($teams as $k){
            foreach($teams as $j){
                if($k==$j){ break; }
                $z = array($k->name,$j->name);
                //sort($z);
                if(!in_array($z,$this->results)){
                    $this->results[] = $z;
                }
            }
        }

        shuffle($this->results);
    }
}
