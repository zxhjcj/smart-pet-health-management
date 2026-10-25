using System.Text;

public static class AiAdvisor
{
    public static string Reply(string petName, string question)
    {
        string text = question == null ? "" : question.ToLower();
        StringBuilder result = new StringBuilder();
        string name = string.IsNullOrEmpty(petName) ? "宠物" : petName;

        result.Append("针对");
        result.Append(name);
        result.Append("的情况，建议如下：\n");

        if (text.Contains("发烧") || text.Contains("体温") || text.Contains("temperature"))
        {
            result.Append("1. 先使用宠物专用体温计复测体温，记录测量时间和数值。\n");
            result.Append("2. 如果体温持续偏高、精神差或拒食，应尽快就医。\n");
        }
        else if (text.Contains("呕吐") || text.Contains("腹泻") || text.Contains("拉稀"))
        {
            result.Append("1. 暂停不易消化的食物，观察饮水、排便次数和精神状态。\n");
            result.Append("2. 若频繁呕吐、便血、幼宠或老年宠物出现脱水迹象，应及时就医。\n");
        }
        else if (text.Contains("疫苗") || text.Contains("驱虫"))
        {
            result.Append("1. 查看系统中的疫苗和驱虫记录，优先按兽医建议的周期执行。\n");
            result.Append("2. 到期前可在系统中建立站内提醒，避免漏接种或漏驱虫。\n");
        }
        else if (text.Contains("体重") || text.Contains("肥胖") || text.Contains("瘦"))
        {
            result.Append("1. 建议连续记录体重趋势，不要只看单次数据。\n");
            result.Append("2. 饮食调整应循序渐进，搭配适量运动，避免突然节食。\n");
        }
        else
        {
            result.Append("1. 继续记录症状、食欲、体温、排便和精神状态。\n");
            result.Append("2. 如果症状持续超过 24 小时或出现明显疼痛、抽搐、呼吸异常，应尽快就医。\n");
        }

        result.Append("\n系统建议仅供参考，严重情况请及时就医。");
        return result.ToString();
    }
}

