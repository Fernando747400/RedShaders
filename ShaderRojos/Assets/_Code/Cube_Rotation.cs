using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cube_Rotation : MonoBehaviour
{
    public float Speed = 5;
    public float xRotation = 3;
    public float yRotation = 4;
    public float zRotation = 7;


    private void FixedUpdate()
    {
        float time = Time.deltaTime * Speed;
        this.gameObject.transform.Rotate(xRotation * time,yRotation * time,zRotation * time,Space.Self);
    }
}
