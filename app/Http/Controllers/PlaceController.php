<?php

namespace App\Http\Controllers;

use App\Http\Requests\PlacePostRequest;
use Illuminate\Http\Request;
use App\Models\Place;

class PlaceController extends Controller{

    public function index(){
        $places=Place::all();
        //return $schools;
        return response()->json($places);
    }

    public function show(Place $place){
        $place=Place::find($place);
        return response()->json($place);
    }

    public function store(PlacePostRequest $request){
        $place = Place::create($request->all());
        return response()->json([
            'message' => "record saved successfully!",
            'place' => $place
        ], 200);
    }

    public function update(PlacePostRequest $request, Place $place){
        $place->update($request->all());

        return response()->json([
            'message' => "record updated successfully!",
            'place' => $place
        ], 200);
    }

    public function destroy(Place $place){
        $place->delete();
        return response()->json([
            'message' => "record deleted successfully!",
        ], 200);
    }

}
